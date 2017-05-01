class Transaction < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user
  has_many :orders

  validates :user_name, presence: true
  validates :restaurant_id, presence: true
end
