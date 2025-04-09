class Request < ApplicationRecord
    belongs_to :requester, class_name: "User"
    belongs_to :recipient, class_name: "User"
  
    validates :amount, numericality: { greater_than: 0 }
  end
  