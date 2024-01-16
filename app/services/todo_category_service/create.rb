# frozen_string_literal: true

module TodoCategoryService
  class Create
    include BaseService

    def initialize(todo_id:, category_ids:)
      @todo_id = todo_id
      @category_ids = category_ids
      @created_records = []
    end

    def execute
      validate_todo
      @category_ids.each do |category_id|
        validate_category(category_id)
        next if TodoCategory.exists?(todo_id: @todo_id, category_id: category_id)

        @created_records << TodoCategory.create!(todo_id: @todo_id, category_id: category_id)
      end
      @created_records
    rescue StandardError => e
      logger.error(e.message)
      raise
    end

    private

    def validate_todo
      raise 'Todo not found' unless Todo.exists?(@todo_id)
    end

    def validate_category(category_id)
      raise "Category with id #{category_id} not found" unless Category.exists?(category_id)
    end
  end
end
