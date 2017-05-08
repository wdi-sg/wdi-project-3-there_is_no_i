class Table < ApplicationRecord
  has_many :invoices
  belongs_to :restaurant, optional: true
  has_many :reservations


  # validates :restaurant_id, presence: true
  validates :name, presence: true
  validates :capacity_total, presence: true
end
