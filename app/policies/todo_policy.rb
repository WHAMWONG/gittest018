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

  def destroy?
    # Check if the current user is the owner of the To-Do item
    todo.user_id == user.id
  end

  # The existing code has a method `confirm_delete?` which seems to be doing the same thing as `destroy?`.
  # To resolve the conflict, we can alias `confirm_delete?` to `destroy?` to keep the existing code working.
  alias_method :confirm_delete?, :destroy?
end
