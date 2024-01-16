json.set! :status, @status_code

if @error_message.present?
  json.error_message @error_message
else
  json.message "Audit log has been successfully created."
end

json.user_id @audit_log.user_id
json.timestamp @audit_log.timestamp
