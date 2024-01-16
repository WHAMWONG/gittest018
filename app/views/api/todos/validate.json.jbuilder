json.status @status_code
json.message @message

if @errors.present?
  json.errors do
    @errors.each do |field, messages|
      json.set! field, messages
    end
  end
end
