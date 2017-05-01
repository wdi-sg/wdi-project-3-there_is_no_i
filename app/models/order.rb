class Order < ApplicationRecord
  # has_many :menu_items

  validates :restaurant_id, presence: true
  validates :item_id, presence: true
  validates :transaction_id, presence: true
  # validates :is_take_away, presence: true
end
