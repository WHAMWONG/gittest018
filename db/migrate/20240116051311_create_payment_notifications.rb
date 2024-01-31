class CreatePaymentNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_notifications do |t|
      t.string :status
      t.text :notification_details
      t.datetime :received_at
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
