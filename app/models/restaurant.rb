class Restaurant < ApplicationRecord
  has_many :invoices
  has_many :menu_items
  has_many :ordered_items, through: :orders, source: :menu_item
  has_many :orders, through: :invoices
  has_many :reservations
  has_many :tables
  has_many :reviews
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :address1, presence: true
  validates :address_city, presence: true
  validates :address_country, presence: true
  validates :address_postal, presence: true
  # validates :description, presence: true
  validates :cuisine, presence: true
end
