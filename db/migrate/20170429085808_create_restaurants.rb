class CreateRestaurants < ActiveRecord::Migration[5.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :address_city
      t.string :address_state
      t.string :address_country
      t.string :address_postal
      t.string :email
      t.string :phone
      t.string :website
      t.string :description
      t.string :cuisine
      t.integer :rating
      t.string :picture
      t.integer :next_queue_number

      t.timestamps
    end
  end
end
