class TodoPolicy < ApplicationPolicy
  def create?
    # For now, we allow any authenticated user to create a todo item.
    # This can be expanded later with more complex logic if needed.
    # Assuming `user` is the authenticated user object from Pundit context.
    !user.nil?
  end
end

end
