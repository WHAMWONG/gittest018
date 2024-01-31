class AddColumnsToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :address, :string
    add_column :users, :phone_number, :string
  end

  def down
    remove_column :users, :address
    remove_column :users, :phone_number
  end
end
