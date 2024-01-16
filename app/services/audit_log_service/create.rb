module AuditLogService
  class Create < BaseService
    def initialize(user_id:, action:, entity_type:, entity_id:, timestamp:)
      @user_id = user_id
      @action = action
      @entity_type = entity_type
      @entity_id = entity_id
      @timestamp = timestamp
    end

    def call
      begin
        AuditLog.create!(
          user_id: @user_id,
          action: @action,
          entity_type: @entity_type,
          entity_id: @entity_id,
          timestamp: @timestamp
        )
      rescue => e
        return { error: e.message }
      end
    end
  end
end
