module Api
  class TodosController < Api::BaseController
    before_action :doorkeeper_authorize!

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

    private

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
  end
end
