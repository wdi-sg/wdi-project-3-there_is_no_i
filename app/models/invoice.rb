class Invoice < ApplicationRecord
  has_many :menu_items, through: :orders
  has_many :orders
  belongs_to :reservation, optional: true
  belongs_to :restaurant
  belongs_to :table, optional: true
  belongs_to :user, optional: true

  validates :restaurant_id, presence: true
end
