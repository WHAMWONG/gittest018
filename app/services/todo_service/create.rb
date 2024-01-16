
module TodoService
  class Create
    include ActiveModel::Model
    include TodoCategoryService::Create

    attr_accessor :user_id, :title, :description, :due_date, :priority, :is_recurring, :recurrence, :category_ids

    validates :title, presence: true
    validates :due_date, presence: true, date: { after: Proc.new { Time.now }, message: I18n.t('activerecord.errors.messages.datetime_in_future') }
    validates :priority, inclusion: { in: Todo.priorities.keys }
    validate :validate_recurrence, if: -> { is_recurring }
    validate :validate_category_ids, if: -> { category_ids.present? }
    validates :title, length: { minimum: 10 }
    validate :validate_title_uniqueness_within_user_todos

    def initialize(attributes = {})
      super
    end

    def call
      return errors.full_messages unless valid?

      user = User.find_by(id: user_id)
      return I18n.t('activerecord.errors.messages.user_not_found') unless user && TodoPolicy.new(user, Todo.new).create?

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
        # Assuming TodoCategoryService::Create is a module that includes the logic to create todo_category records

        return { todo_id: todo.id }
      end
    rescue ActiveRecord::RecordInvalid => e
      return e.record.errors.full_messages
    end

    private

    def validate_recurrence
      errors.add(:recurrence, I18n.t('activerecord.errors.messages.invalid_recurrence')) unless Todo.recurrences.include?(recurrence)
    end

    def validate_title_uniqueness_within_user_todos
      if user_id && title.present? && Todo.exists?(user_id: user_id, title: title)
        errors.add(:title, I18n.t('activerecord.errors.messages.taken'))
      end
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
