# typed: strict
class Payment < ApplicationRecord
  belongs_to :user
  has_many :payment_notifications, dependent: :destroy

  # validations
  validates :amount, :currency, :payment_method, :status, :transaction_id, :user_id, presence: true
  # end for validations

  class << self
  end
end
