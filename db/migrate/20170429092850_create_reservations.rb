class CreateReservations < ActiveRecord::Migration[5.0]
  def change
    create_table :reservations do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :phone
      t.string :email
      t.integer :party_size
      t.string :special_requests
      t.datetime :start_time
      t.references :restaurant, foreign_key: true
      t.boolean :is_queuing
      t.references :table, foreign_key: true
      t.datetime :end_time

      t.timestamps
    end
  end
end
