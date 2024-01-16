
module TodoService
  class Delete < BaseService
    include ActiveModel::Validations

    validates :user_id, numericality: true
    validates :action, inclusion: { in: ['delete'] }
    validates :entity_type, inclusion: { in: ['todo'] }
    validates :entity_id, numericality: true
    validate :timestamp_must_be_datetime

    def initialize(todo_id, user, params = {})
      @todo_id = todo_id
      @user = user
      @params = params
      super()
    end

    def timestamp_must_be_datetime
      errors.add(:timestamp, 'Wrong date format.') unless @params[:timestamp].is_a?(DateTime)
    end

    def call
      validate_params!

      todo = @user.todos.find_by(id: @todo_id)

      if todo
        todo.destroy
        create_audit_log
        { success: true, message: 'To-Do item has been deleted.' }
      else
        { success: true, message: 'To-Do item has already been deleted or does not exist.' }
      end
    rescue => e
      { success: false, message: e.message }
    end

    private

    def validate_params!
      assign_attributes(@params)
      raise StandardError.new(errors.full_messages.join(', ')) unless valid?
    end

    def assign_attributes(attrs)
      attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    def create_audit_log
      AuditLog.create(
        user_id: @user.id,
        action: 'delete',
        entity_type: 'todo',
        entity_id: @todo_id,
        timestamp: Time.current
      )
    end
  end
end
