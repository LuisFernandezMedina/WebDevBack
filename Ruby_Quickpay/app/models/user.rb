class User < ApplicationRecord
  has_secure_password  # No lleva argumentos

  has_many :transactions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  before_save :downcase_email

  ROLE_CLIENT = 0
  ROLE_ADMIN = 1

  def role_enum
    { client: ROLE_CLIENT, admin: ROLE_ADMIN }
  end

  def role_name
    role_enum.key(self.role)
  end

  def client?
    self.role == ROLE_CLIENT
  end

  def admin?
    self.role == ROLE_ADMIN
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
