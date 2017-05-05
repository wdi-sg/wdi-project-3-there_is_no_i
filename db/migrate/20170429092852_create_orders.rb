class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :menu_item, foreign_key: true
      t.text :request_description
      t.references :invoice
      t.boolean :is_take_away
      t.datetime :time_end

      t.timestamps
    end
  end
end
