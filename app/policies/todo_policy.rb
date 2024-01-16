
class TodoPolicy < ApplicationPolicy
  attr_reader :user, :todo

  def initialize(user, todo)
    @user = user
    @todo = todo
  end

  def validate?
    user.present?
  end

  def create?
    # For now, we allow any authenticated user to create a todo item.
    # This can be expanded later with more complex logic if needed.
    # Assuming `user` is the authenticated user object from Pundit context.
    !user.nil?
  end

  def confirm_delete?
    user.id == todo.user_id
  end

end
