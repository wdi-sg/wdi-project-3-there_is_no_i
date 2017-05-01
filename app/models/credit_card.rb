class CreditCard < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :number, presence: true
  validates :type, presence: true
  validates :expiry_month, presence: true
  validates :expiry_year, presence: true
end
