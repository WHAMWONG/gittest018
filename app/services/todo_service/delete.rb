module TodoService
  class Delete < BaseService
    def initialize(todo_id, user)
      @todo_id = todo_id
      @user = user
    end

    def call
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
