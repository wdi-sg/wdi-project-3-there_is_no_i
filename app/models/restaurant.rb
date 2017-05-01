class Restaurant < ApplicationRecord
  validates :name, presence: true
  validates :address1, presence: true
  validates :address_city, presence: true
  # validates :address_state, presence: true
  validates :address_country, presence: true
  # validates :address_postal, presence: true
  validates :description, presence: true
  validates :cuisine, presence: true
  validates :email, presence: true
  # validates :password, presence: true
end
