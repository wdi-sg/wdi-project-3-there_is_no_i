class Review < ApplicationRecord
  validates :restaurant_id, presence: true
  validates :rating, presence: true
end
