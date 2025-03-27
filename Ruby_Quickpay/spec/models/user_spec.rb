require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(name: "Test User", email: "test@example.com", password: "password", balance: 100)
  end

  it "es válido con atributos correctos" do
    expect(@user).to be_valid
  end

  it "requiere un nombre" do
    @user.name = nil
    expect(@user).not_to be_valid
  end

  it "requiere un email válido y único" do
    User.create!(name: "Another User", email: "test@example.com", password: "password", balance: 50)
    expect(@user).not_to be_valid
  end

  it "requiere una contraseña de al menos 6 caracteres" do
    @user.password = "123"
    expect(@user).not_to be_valid
  end

  it "tiene un saldo que no puede ser negativo" do
    @user.balance = -10
    expect(@user).not_to be_valid
  end

  it "convierte el email a minúsculas antes de guardar" do
    @user.email = "TEST@EXAMPLE.COM"
    @user.save
    expect(@user.reload.email).to eq("test@example.com")
  end
end
