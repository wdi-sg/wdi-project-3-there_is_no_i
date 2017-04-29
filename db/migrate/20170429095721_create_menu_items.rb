class CreateMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :menu_items do |t|
      t.integer :restaurant_id
      t.string :name
      t.float :price
      t.text :description
      t.text :ingredients
      t.text :tags

      t.timestamps
    end
  end
end
