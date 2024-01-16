class ChangeSchemaV2 < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_logs, comment: 'Stores audit logs for tracking changes in the application' do |t|
      t.string :entity_type

      t.string :action

      t.integer :entity_id

      t.datetime :timestamp

      t.timestamps null: false
    end

    change_table_comment :todos, from: 'Stores todo items created by users', to: 'Stores to-do items for users'

    add_column :todos, :is_completed, :boolean

    add_column :users, :username, :string

    add_reference :audit_logs, :user, foreign_key: true
  end
end
