class GroupRequestParticipant < ApplicationRecord
  belongs_to :group_request
  belongs_to :participant, class_name: "User"

  validates :amount, numericality: { greater_than: 0 }
  validates :paid, inclusion: { in: [true, false] }

  scope :pending, -> { where(paid: false) }
  scope :paid, -> { where(paid: true) }
end
