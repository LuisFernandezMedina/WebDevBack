class GroupRequest < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :group_request_participants, dependent: :destroy

  validates :total_amount, numericality: { greater_than: 0 }
  validates :description, presence: true

  def completed?
    group_request_participants.all?(&:paid)
  end

  def amount_paid
    group_request_participants.where(paid: true).sum(:amount)
  end
end
