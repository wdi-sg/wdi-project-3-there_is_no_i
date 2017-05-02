class Reservation < ApplicationRecord
  # belongs_to :restaurant

  # validates :user_name, presence: true
  validates :party_size, presence: true
  validates :restaurant_id, presence: true
  # validates :start_time, presence: true
  # validates :is_queuing, presence: true
  # validates :table_id, presence: true
end
