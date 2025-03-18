class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize_request, only: [:create, :login]  # 🔹 Permite registro y login sin autenticación

  before_action :set_user, only: %i[show update destroy]
  
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
            render json: { token: token, user: @user }, status: :ok
        else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
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
      render json: @user
    end
  
    # PATCH/PUT /users/:id
    def update

      if @current_user.id == @user.id || @current_user.admin?
        if @user.update(user_update_params)
          render json: { message: "User updated successfully", user: @user }, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
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
  