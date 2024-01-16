# frozen_string_literal: true

module TodoService
  class AttachFiles < BaseService
    attr_reader :todo_id, :file_paths

    def initialize(todo_id, file_paths)
      @todo_id = todo_id
      @file_paths = file_paths
    end

    def call
      todo = Todo.find(todo_id)
      attached_files = []

      file_paths.each do |file_path|
        begin
          raise StandardError, "File does not exist or is not accessible" unless File.exist?(file_path)

          attachment = todo.attachments.create!(file_path: file_path)
          attached_files << attachment
        rescue StandardError => e
          logger.error "Failed to attach file: #{file_path}, Error: #{e.message}"
        end
      end

      attached_files
    rescue ActiveRecord::RecordNotFound => e
      logger.error "Todo not found: #{e.message}"
      raise
    end
  end
end
