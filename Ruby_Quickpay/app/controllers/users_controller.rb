class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize_request, only: [:create, :login, :show_by_email]  # 🔹 Permite registro y login sin autenticación
  
  Rails.application.config.filter_parameters -= [:email]


  before_action :set_user, only: %i[show update destroy]
  
    def index
      users = User.all.select(:id, :name, :email, :balance, :role)
      render json: users
    end
  
    def show_by_email
      Rails.logger.debug "Email recibido: #{email}"
      email = CGI.unescape(params[:email])
    
      Rails.logger.debug "Email recibido: #{email}"
    
      user = User.find_by(email: email)
    
      if user
        render json: user
      else
        render json: { error: 'Usuario no encontrado' }, status: :not_found
      end
    end
  
    # POST /signup
    def create
      @user = User.new(user_params)
      if @user.save
        token = JsonWebToken.encode(user_id: @user.id, role: @user.role)
        render json: { token: token, user: @user }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /login
    def login
      @user = User.find_by(email: params[:email])
    
      if @user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: @user.id, role: @user.role)
        render json: { token: token, user: @user.slice(:id, :name, :email, :balance, :role) }, status: :ok
      else
        render json: { error: 'Correo o contraseña inválidos' }, status: :unauthorized
      end
    end

      # POST /users/request_money
    def request_money
      card_response = HTTParty.get("http://localhost:3001/payment_cards", query: { card_number: params[:card_number], cardholder_name: params[:cardholder_name], cvv: params[:cvv] })
      
      if card_response.code == 200
        amount = params[:amount].to_f
        @current_user.update(balance: @current_user.balance + amount)
        render json: { message: 'Money added successfully', new_balance: @current_user.balance }, status: :ok
      else
        render json: { error: 'Card validation failed' }, status: :unprocessable_entity
      end
    end
    
    # GET /users/:id
    def show
      if @current_user.admin?
        user = User.find_by(id: params[:id])
        if user
          render json: user.slice(:id, :name, :email, :balance, :role)
        else
          render json: { error: 'Usuario no encontrado' }, status: :not_found
        end
      elsif @current_user.id.to_s == params[:id]
        render json: @current_user.slice(:id, :name, :email, :balance, :role)
      else
        render json: { error: 'No autorizado' }, status: :unauthorized
      end
    end

    # PATCH/PUT /users/:id
    def update
      if @current_user.update(user_update_params)
        render json: { message: "Perfil actualizado", user: @current_user }, status: :ok
      else
        render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
        
  
    # DELETE /users/:id
    def destroy

      if @current_user.id == @user.id || @current_user.admin?
        @user.destroy
        head :no_content
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # PATCH/PUT /users/:id
    def update
      if @current_user.update(user_update_params)
        # Si se proporciona una contraseña nueva, se asegura que se hashee correctamente
        if params[:password].present?
          @current_user.password = params[:password]
          unless @current_user.save
            return render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        render json: { message: "Perfil actualizado", user: @current_user.slice(:id, :name, :email, :balance, :role) }, status: :ok
      else
        render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /users/:id/add_balance
    def add_balance
      amount = params[:amount].to_f
      if amount > 0
        @current_user.update(balance: @current_user.balance + amount)
        render json: { message: "Saldo añadido correctamente", new_balance: @current_user.balance }, status: :ok
      else
        render json: { error: "Cantidad inválida" }, status: :unprocessable_entity
      end
    end

    # PATCH /users/:id/retire_balance
    def retire_balance
      amount = params[:amount].to_f
      if amount > 0 && @current_user.balance >= amount
        @current_user.update(balance: @current_user.balance - amount)
        render json: { message: "Saldo retirado correctamente", new_balance: @current_user.balance }, status: :ok
      else
        render json: { error: "Saldo insuficiente o cantidad inválida" }, status: :unprocessable_entity
      end
    end

    # POST /users/transfer_money
    def transfer_money
      sender = User.find_by(id: params[:sender_id])
      receiver = User.find_by(id: params[:receiver_id])
      amount = params[:amount].to_f

      if sender.nil? || receiver.nil?
        return render json: { error: "Usuario no encontrado" }, status: :not_found
      end

      if amount <= 0
        return render json: { error: "Cantidad inválida" }, status: :unprocessable_entity
      end

      if sender.balance < amount
        return render json: { error: "Saldo insuficiente" }, status: :unprocessable_entity
      end

      # Transacción atómica
      ActiveRecord::Base.transaction do
        sender.update!(balance: sender.balance - amount)
        receiver.update!(balance: receiver.balance + amount)
        Transaction.create!(
          sender: sender,
          receiver: receiver,
          amount: amount,
          date: Time.current
        )
      end

      render json: { message: "Transferencia completada", sender_balance: sender.balance, receiver_balance: receiver.balance }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
    def transactions
      user = User.find(params[:id])
      sent = user.sent_transactions.includes(:receiver).map do |t|
        {
          id: t.id,
          to: t.receiver.name,
          to_email: t.receiver.email,
          amount: t.amount,
          date: t.date
        }
      end
    
      received = user.received_transactions.includes(:sender).map do |t|
        {
          id: t.id,
          from: t.sender.name,
          from_email: t.sender.email,
          amount: t.amount,
          date: t.date
        }
      end
    
      render json: {
        sent: sent,
        received: received
      }
    end
    



    private
  
    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end
  
    def user_params
      params.permit(:name, :email, :password, :role)
    end
    
    def user_update_params
      params.permit(:name, :password)
    end

    
    
    
    
  end