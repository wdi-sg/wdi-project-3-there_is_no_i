class Transaction < ApplicationRecord
  # belongs_to :restaurant
  # belongs_to :user
  # belongs_to :reservation # might be 0
  # belongs_to :table # might be 0
  # has_many :orders

  # validates :user_name, presence: true
  validates :restaurant_id, presence: true
end
