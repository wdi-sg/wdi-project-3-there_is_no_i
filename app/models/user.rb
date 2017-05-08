class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :invoices
  has_and_belongs_to_many :restaurants
  has_many :reviews
  has_many :reservations
  has_many :orders, through: :invoices

  validates :name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
end
