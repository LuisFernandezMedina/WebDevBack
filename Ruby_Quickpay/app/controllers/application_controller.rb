class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    if token.blank?
      return render json: { error: "Token not provided" }, status: :unauthorized
    end

    decoded = JsonWebToken.decode(token)

    if decoded.nil? || decoded["user_id"].nil?
      return render json: { error: "Invalid token" }, status: :unauthorized
    end

    @current_user = User.find_by(id: decoded["user_id"])

    unless @current_user
      return render json: { error: "User not found" }, status: :unauthorized
    end
  rescue => e
    render json: { error: "Authorization error: #{e.message}" }, status: :unauthorized
  end
end
