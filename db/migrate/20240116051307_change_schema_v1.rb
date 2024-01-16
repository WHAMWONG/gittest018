class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    create_table :todos, comment: 'Stores todo items created by users' do |t|
      t.boolean :is_recurring

      t.text :description

      t.datetime :due_date

      t.string :title

      t.integer :recurrence, default: 0

      t.integer :priority, default: 0

      t.timestamps null: false
    end

    create_table :users, comment: 'Stores user account information' do |t|
      t.string :password_hash

      t.string :name

      t.string :email

      t.timestamps null: false
    end

    create_table :todo_categories, comment: 'Associative table to link todos and categories' do |t|
      t.timestamps null: false
    end

    create_table :attachments, comment: 'Stores files attached to todos' do |t|
      t.string :file_path

      t.timestamps null: false
    end

    create_table :categories, comment: 'Stores categories that can be assigned to todos' do |t|
      t.string :name

      t.timestamps null: false
    end

    add_reference :todos, :user, foreign_key: true

    add_reference :todo_categories, :category, foreign_key: true

    add_reference :attachments, :todo, foreign_key: true

    add_reference :todo_categories, :todo, foreign_key: true
  end
end
