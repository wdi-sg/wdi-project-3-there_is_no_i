class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :table_id
      t.integer :user_id
      t.integer :restaurant_id
      t.integer :item_id
      t.text :request_description
      t.integer :transaction_id
      t.boolean :is_take_away
      t.datetime :time_end

      t.timestamps
    end
  end
end
