class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone
      # t.string :password
      t.string :password_digest
      t.integer :restaurant_id

      t.timestamps
      # rename_column("users", "password", "password_digest")
    end
  end
end
