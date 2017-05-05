class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.references :restaurant, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :rating
      t.text :comments

      t.timestamps
    end
  end
end
