class User < ApplicationRecord
    enum role: { user: 0, admin: 1 }
  
    validates :name, presence: true, length: { minimum: 2 }
    #validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
    validates :credit_card_number, presence: true, length: { is: 16 }, numericality: { only_integer: true }
  
    before_save :downcase_email
  
    private
  
    def downcase_email
      self.email = email.downcase
    end
  end