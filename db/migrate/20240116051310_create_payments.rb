class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.string :currency
      t.string :payment_method
      t.string :status
      t.string :transaction_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
