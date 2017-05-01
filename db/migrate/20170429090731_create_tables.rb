class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table :tables do |t|
      t.references :restaurant, foreign_key: true
      t.string :name
      t.integer :capacity_total
      t.integer :capacity_current
      t.datetime :time_start
      t.datetime :time_end

      t.timestamps
    end
  end
end
