class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :user_name
      t.integer :table_id
      t.integer :restaurant_id
      t.datetime :time_end
      t.datetime :takeaway_time

      t.timestamps
    end
  end
end
