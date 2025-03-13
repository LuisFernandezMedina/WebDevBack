class UsersController < ApplicationController
    before_action :authorize_request, except: :create
    before_action :set_user, only: %i[show update destroy]
  
    # POST /signup
    def create
      @user = User.new(user_params)
      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /login
    def login
        @user = User.find_by(email: params[:email])
    
        if @user&.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: @user.id)
            render json: { token: token, user: @user }, status: :ok
        else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
    end
  
    # GET /users/:id
    def show
      render json: @user
    end
  
    # PATCH/PUT /users/:id
    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /users/:id
    def destroy
      @user.destroy
      head :no_content
    end
  
    private
  
    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end
  
    def user_params
      params.permit(:name, :email, :password, :credit_card_number, :cvv, :cardholder_name, :role)
    end
  end
  