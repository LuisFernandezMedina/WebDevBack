require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/password_resets/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /validate" do
    it "returns http success" do
      get "/password_resets/validate"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/password_resets/update"
      expect(response).to have_http_status(:success)
    end
  end

end
