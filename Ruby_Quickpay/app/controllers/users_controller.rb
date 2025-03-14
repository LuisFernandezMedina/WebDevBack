class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
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
            token = JsonWebToken.encode(user_id: @user.id, role: @user.role)
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
      Rails.logger.debug "🛠 Intentando actualizar usuario con ID: #{@user.id}"
      Rails.logger.debug "🔹 Usuario autenticado: #{@current_user.inspect}"
    
      if @current_user.id == @user.id || @current_user.admin?  # ✅ Permitir si es su perfil o es admin
        if @user.update(user_update_params)
          Rails.logger.debug "✅ Usuario actualizado correctamente"
          render json: { message: "User updated successfully", user: @user }, status: :ok
        else
          Rails.logger.debug "❌ Error en la actualización: #{@user.errors.full_messages}"
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        Rails.logger.debug "⛔ Usuario no autorizado para esta operación"
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    rescue StandardError => e
      Rails.logger.error "🔥 Error inesperado en update: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error  # 🔹 Captura errores inesperados
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
      params.permit(:name, :password)
    end
    
    def user_update_params
      params.permit(:name, :password)
    end
    
  end
  