class PasswordResetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize_request
  def create
    user = User.find_by(email: params[:email].downcase)
    return render json: { error: "Email no encontrado" }, status: :not_found unless user
  
    PasswordResetToken.where(user: user).delete_all
    token = PasswordResetToken.create!(user: user)
  
    url = "#{ENV['APP_URL']}/reset-password?token=#{token.token}"
    mensaje_html = render_to_string(
      template: "user_mailer/password_reset",
      layout: false,
      formats: [:html],
      locals: { user: user, reset_url: url }
    )
  
    EmailService.new.enviar_email(user.email, "Recuperación de contraseña", mensaje_html)
  
    render json: { message: "Correo de recuperación enviado" }, status: :ok
  end
  
  

  def validate
    token = PasswordResetToken.find_by(token: params[:token])
    if token && !token.expired?
      render json: { message: "Token válido" }, status: :ok
    else
      render json: { error: "Token inválido o expirado" }, status: :bad_request
    end
  end

  def update
    token = PasswordResetToken.find_by(token: params[:token])
    if token.nil? || token.expired?
      return render json: { error: "Token inválido o expirado" }, status: :bad_request
    end

    user = token.user
    if params[:password] != params[:password_confirmation]
      return render json: { error: "Las contraseñas no coinciden" }, status: :unprocessable_entity
    end

    if user.update(password: params[:password])
      token.destroy
      render json: { message: "Contraseña actualizada con éxito" }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
