json.set! :status, 201

if @todo.errors.any?
  json.errors @todo.errors.full_messages
else
  json.todo do
    json.id @todo.id
    json.user_id @todo.user_id
    json.title @todo.title
    json.description @todo.description
    json.due_date @todo.due_date
    json.priority @todo.priority
    json.is_recurring @todo.is_recurring
    json.created_at @todo.created_at
  end
end
