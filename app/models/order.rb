class Order < ApplicationRecord
  # belongs_to :menu_items
  belongs_to :transaction
  # belongs_to :user
  # belongs_to :restaurant

  validates :restaurant_id, presence: true
  validates :item_id, presence: true
  validates :transaction_id, presence: true
  # validates :is_take_away, presence: true
end
