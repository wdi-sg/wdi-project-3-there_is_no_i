class Order < ApplicationRecord
  belongs_to :menu_item
  belongs_to :invoice
  # belongs_to :user
  # belongs_to :restaurant

  # validates :menu_item_id, presence: true
  # validates :invoice_id, presence: true
  # validates :is_take_away, presence: true
end
