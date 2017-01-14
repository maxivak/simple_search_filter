class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :client_id

      t.timestamps null: false
    end
  end
end
