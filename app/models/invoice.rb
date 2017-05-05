class Invoice < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user, optional: true
  # belongs_to :reservation # might be 0
  # belongs_to :table # might be 0
  has_many :orders
  has_many :menu_items, through: :orders

  # validates :user_name, presence: true
  validates :restaurant_id, presence: true
end
