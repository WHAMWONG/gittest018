# frozen_string_literal: true

class ValidateTodoDetailsService < BaseService
  attr_reader :title, :due_date, :user_id

  def initialize(title:, due_date:, user_id:)
    @title = title
    @due_date = due_date
    @user_id = user_id
  end

  def call
    validate_title_presence &&
    validate_title_length &&
    validate_due_date &&
    validate_uniqueness_of_title
  end

  private

  def validate_title_presence
    return true unless title.blank?
    [false, I18n.t('activerecord.errors.messages.blank')]
  end

  def validate_title_length
    return true if title.length <= 255
    [false, I18n.t('activerecord.errors.messages.too_long', count: 255)]
  end

  def validate_due_date
    return [false, I18n.t('activerecord.errors.messages.datetime_in_past')] if due_date < Time.current
    return [false, I18n.t('activerecord.errors.messages.invalid')] unless due_date.is_a?(DateTime)
    true
  end

  def validate_uniqueness_of_title
    existing_todo = Todo.find_by(title: title, user_id: user_id)
    return true unless existing_todo
    [false, I18n.t('activerecord.errors.messages.taken')]
  end
end
