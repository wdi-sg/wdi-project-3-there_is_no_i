class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references :table, foreign_key: true
      t.references :user, foreign_key: true
      t.references :restaurant, foreign_key: true
      t.references :menu_item, foreign_key: true
      # t.integer :item_id
      t.text :request_description
      t.references :transaction, foreign_key: true
      # t.integer :transaction_id
      t.boolean :is_take_away
      t.datetime :time_end

      t.timestamps
    end
  end
end
