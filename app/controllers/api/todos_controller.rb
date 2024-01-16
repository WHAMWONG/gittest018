module Api
  class TodosController < Api::BaseController
    before_action :doorkeeper_authorize!
    before_action :set_todo, only: [:create_attachments, :link_categories]

    # POST /api/todos
    def create
      todo_service = TodoService::Create.new(create_params)

      if todo_service.valid?
        result = todo_service.call
        if result.is_a?(Hash) && result[:todo_id]
          todo = Todo.find(result[:todo_id])
          render json: { status: 201, todo: todo }, status: :created
        else
          render json: { errors: result }, status: :unprocessable_entity
        end
      else
        render json: { errors: todo_service.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue Pundit::NotAuthorizedError => e
      render json: { error: e.message }, status: :unauthorized
    end

    # POST /api/todos/:todo_id/attachments
    def create_attachments
      begin
        file_paths = params.require(:file_paths)

        raise ActionController::ParameterMissing, 'todo_id' unless params[:todo_id]
        raise ActionController::ParameterMissing, 'file_paths' if file_paths.empty?

        attachments = TodoService::AttachFiles.new(@todo.id, file_paths).call

        if attachments.any?
          render json: { status: 200, message: 'Files attached to todo successfully.' }, status: :ok
        else
          render json: { status: 422, message: 'No files were attached.' }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { status: 404, message: 'Todo not found.' }, status: :not_found
      rescue ActionController::ParameterMissing => e
        render json: { status: 400, message: e.message }, status: :bad_request
      end
    end

    # POST /api/todos/:todo_id/categories
    def link_categories
      category_ids = params.require(:category_ids)

      begin
        TodoCategoryService::Create.new(todo_id: @todo.id, category_ids: category_ids).execute
        render json: { status: 200, message: 'Todo linked with categories successfully.' }, status: :ok
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    def validate
      validator = ValidateTodoDetailsService.new(
        title: params[:title],
        due_date: params[:due_date],
        user_id: current_resource_owner.id
      )

      is_valid, message = validator.call

      if is_valid
        render json: { status: 200, message: 'Todo details are valid.' }, status: :ok
      else
        case message
        when I18n.t('activerecord.errors.messages.taken')
          render json: { error: message }, status: :conflict
        when I18n.t('activerecord.errors.messages.invalid'), I18n.t('activerecord.errors.messages.datetime_in_past')
          render json: { error: message }, status: :unprocessable_entity
        else
          render json: { error: message }, status: :bad_request
        end
      end
    end

    # GET /api/todos/:id/confirm_delete
    def confirm_delete
      doorkeeper_authorize!
      begin
        id = params[:id]
        raise ArgumentError unless id.to_s.match?(/\A\d+\z/)

        @todo = current_resource_owner.todos.find(id)
        authorize @todo, policy_class: TodoPolicy

        render json: {
          status: 200,
          message: "Are you sure you want to delete this To-Do item?",
          item: @todo.as_json(only: [:id, :title, :description, :is_completed, :created_at, :updated_at])
        }, status: :ok
      rescue Pundit::NotAuthorizedError
        render json: { error: "User does not have permission to access the resource." }, status: :forbidden
      end
    end

    private

    def set_todo
      @todo = Todo.find(params[:todo_id])
    end

    def create_params
      params.permit(
        :user_id,
        :title,
        :description,
        :due_date,
        :priority,
        :is_recurring,
        :recurrence
      )
    end

    def todo_params
      params.permit(:todo_id, category_ids: [])
    end
  end
end
