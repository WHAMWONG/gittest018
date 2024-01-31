# typed: strict
class PaymentNotification < ApplicationRecord
  belongs_to :payment

  validates :status, presence: true
  validates :notification_details, presence: true
  validates :received_at, presence: true
  validates :payment_id, presence: true
end
