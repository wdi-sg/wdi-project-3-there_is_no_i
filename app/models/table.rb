class Table < ApplicationRecord
  # belongs_to :restaurant
  # has_many :reservations
  # has_many :transactions

  validates :restaurant_id, presence: true
  validates :name, presence: true
  # validates :capacity_total, presence: true
  # validates :capacity_current, presence: true
  # validates :time_start, presence: true
  # validates :time_end, presence: true
end
