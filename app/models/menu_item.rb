class MenuItem < ApplicationRecord
  # belongs_to :restaurant
  # belongs_to :order

  validates :restaurant_id, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :description, presence: true
end
