class Reservation < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :restaurant
  belongs_to :table, optional: true
  belongs_to :user, optional: true

  validates :user_name, presence: true
  validates :party_size, presence: true
  validates :restaurant_id, presence: true
  # validates :start_time, presence: true
end
