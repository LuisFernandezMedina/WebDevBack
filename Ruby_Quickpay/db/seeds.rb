User.find_or_create_by!(email: 'admin@example.com') do |user|
    user.name = 'Admin'
    user.password = 'admin123'          # Cambia la contraseña por algo seguro
    user.password_confirmation = 'admin123'
    user.role = User::ROLE_ADMIN 
    user.balance = 0.0
end
  