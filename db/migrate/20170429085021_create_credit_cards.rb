class CreateCreditCards < ActiveRecord::Migration[5.0]
  def change
    create_table :credit_cards do |t|
      t.integer :user_id
      t.integer :number
      t.string :type
      t.integer :expiry_month
      t.integer :expiry_year

      t.timestamps
    end
  end
end
