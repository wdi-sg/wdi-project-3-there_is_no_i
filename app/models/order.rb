class Order < ApplicationRecord
  # belongs_to :menu_items
  # HEROKU ERROR: "tried to define an association named transaction on the model Order, but this will conflict with a method transaction already defined by Active Record"
  # belongs_to :transaction
  # belongs_to :user
  # belongs_to :restaurant

  validates :restaurant_id, presence: true
  validates :menu_item_id, presence: true
  validates :transaction_id, presence: true
  # validates :is_take_away, presence: true
end
