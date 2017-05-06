class Table < ApplicationRecord
  has_many :invoices
  belongs_to :restaurant
  has_many :reservations


  validates :restaurant_id, presence: true
  validates :name, presence: true
  # validates :capacity_total, presence: true
  # validates :capacity_current, presence: true
  # validates :time_start, presence: true
  # validates :time_end, presence: true
end
