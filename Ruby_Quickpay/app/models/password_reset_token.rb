# app/models/password_reset_token.rb
class PasswordResetToken < ApplicationRecord
  belongs_to :user
  before_create :generate_token_and_expiration

  validates :user_id, uniqueness: true

  def expired?
    Time.current > self.expires_at
  end

  private

  def generate_token_and_expiration
    self.token = SecureRandom.urlsafe_base64
    self.expires_at = 15.minutes.from_now
  end
end
