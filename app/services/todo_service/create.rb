module TodoService
  class Create
    include ActiveModel::Model

    attr_accessor :user_id, :title, :description, :due_date, :priority, :is_recurring, :recurrence, :category_ids

    validates :title, presence: true, uniqueness: { scope: :user_id }
    validates :due_date, presence: true, date: { after: Proc.new { Time.now }, message: I18n.t('activerecord.errors.messages.datetime_in_future') }
    validates :priority, inclusion: { in: Todo.priorities.keys }
    validate :validate_recurrence, if: -> { is_recurring }
    validate :validate_category_ids, if: -> { category_ids.present? }

    def initialize(attributes = {})
      super
    end

    def call
      return errors.full_messages unless valid?

      user = User.find_by(id: user_id)
      return I18n.t('activerecord.errors.messages.invalid') unless user

      Todo.transaction do
        todo = user.todos.create!(
          title: title,
          description: description,
          due_date: due_date,
          priority: priority,
          is_recurring: is_recurring,
          recurrence: recurrence
        )

        link_categories(todo) if category_ids.present?

        return { todo_id: todo.id }
      end
    rescue ActiveRecord::RecordInvalid => e
      return e.record.errors.full_messages
    end

    private

    def validate_recurrence
      errors.add(:recurrence, I18n.t('activerecord.errors.messages.in', count: Todo.recurrences.keys.join(', '))) unless Todo.recurrences.include?(recurrence)
    end

    def validate_category_ids
      category_ids.each do |category_id|
        errors.add(:category_ids, I18n.t('activerecord.errors.messages.invalid')) unless Category.exists?(category_id)
      end
    end

    def link_categories(todo)
      category_ids.each do |category_id|
        todo.todo_categories.create!(category_id: category_id)
      end
    end
  end
end
