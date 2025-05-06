# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
        def password_reset(user, token)
        @user = user
        @reset_url = "#{ENV['APP_URL']}/reset-password?token=#{token}"
        mail(to: @user.email, subject: "Recuperación de contraseña")
        end
end
