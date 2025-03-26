class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize_request, only: [:create, :login, :show_by_email]  # 🔹 Permite registro y login sin autenticación
  
  Rails.application.config.filter_parameters -= [:email]


  before_action :set_user, only: %i[show update destroy]
  
    def show_by_email
      Rails.logger.debug "Email recibido: #{email}"
      email = CGI.unescape(params[:email])
    
      # 🔥 FORZAMOS A LOGUEAR EL EMAIL PARA VER SI LLEGA BIEN
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
      render json: @current_user.slice(:id, :name, :email, :balance, :role)
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