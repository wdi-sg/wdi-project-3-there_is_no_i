class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :invoices
  # has_many :credit_cards
  # has_many :reviews
  # has_many :reservations
  # has_many :orders
  has_and_belongs_to_many :restaurants

  # validates :name, presence: true, length: { minimum: 1 }
  #
  # validates :email, email: true
  # # validates :email, presence: true, length: {minimum: 1}, uniqueness: {case_sensitive: false}, format: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #
  # validates :password, length: { in: 6..72 }, on: :create
  # has_secure_password
  #
  # def self.find_and_authenticate_user(params)
  #   User.find_by_email(params[:email]).try(:authenticate, params[:password])
  # end
end
