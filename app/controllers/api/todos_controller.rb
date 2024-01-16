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
