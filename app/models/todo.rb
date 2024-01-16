
class Todo < ApplicationRecord
  has_many :todo_categories, dependent: :destroy
  has_many :attachments, dependent: :destroy

  belongs_to :user

  enum priority: %w[low medium high], _suffix: true
  enum recurrence: %w[daily weekly monthly], _suffix: true

  # validations
  validates :title, presence: true, length: { maximum: 255, too_long: I18n.t('activerecord.errors.messages.too_long', count: 255) }, uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.messages.taken') }
  validate :due_date_cannot_be_in_the_past, :due_date_must_be_valid_datetime
  # end for validations

  private

  def due_date_cannot_be_in_the_past
    errors.add(:due_date, I18n.t('activerecord.errors.messages.datetime_in_past')) if due_date.present? && due_date < Time.current
  end

  def due_date_must_be_valid_datetime
    errors.add(:due_date, I18n.t('activerecord.errors.messages.invalid')) unless due_date.is_a?(DateTime)
  end

  class << self
  end
end
