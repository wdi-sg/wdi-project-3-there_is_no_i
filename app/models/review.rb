class Review < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user

  validates :restaurant_id, presence: true
  validates :rating, presence: true
  validates :user_id, presence: true
end
