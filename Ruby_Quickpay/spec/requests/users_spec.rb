require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let!(:user) { User.create!(name: "John Doe", email: "john@example.com", password: "password", balance: 100) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }

  describe "POST /signup" do
    it "crea un usuario correctamente" do
      post "/signup", params: { name: "New User", email: "new@example.com", password: "password" }
      expect(response).to have_http_status(:created)
    end

    it "falla si falta un campo" do
      post "/signup", params: { email: "missing_name@example.com", password: "password" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /login" do
    it "devuelve un token si las credenciales son correctas" do
      post "/login", params: { email: user.email, password: "password" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key("token")
    end

    it "devuelve error si las credenciales son incorrectas" do
      post "/login", params: { email: user.email, password: "wrong_password" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /users/:id" do
    it "devuelve los datos del usuario autenticado" do
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["email"]).to eq(user.email)
    end
  end
end
