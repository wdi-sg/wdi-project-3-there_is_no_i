class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true
      t.string :user_name
      t.references :table, foreign_key: true
      t.references :restaurant, foreign_key: true
      t.datetime :time_end
      t.datetime :takeaway_time
      t.references :reservation, foreign_key: true

      t.timestamps
    end
  end
end
