class Transaction < ApplicationRecord
  validates :user_name, presence: true
  validates :restaurant_id, presence: true
end
