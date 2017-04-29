class CreateReservations < ActiveRecord::Migration[5.0]
  def change
    create_table :reservations do |t|
      t.integer :user_id
      t.string :user_name
      t.string :phone
      t.string :email
      t.integer :party_size
      t.integer :restaurant_id
      t.datetime :date_time
      t.boolean :is_queuing
      t.integer :table_id

      t.timestamps
    end
  end
end
