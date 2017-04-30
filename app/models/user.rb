class User < ApplicationRecord
  # has_secure_password
  validates :name, presence: true, length: {minimum: 1}
  validates :email, presence: true, length: {minimum: 1}, uniqueness: {case_sensitive: false}, format: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :password, length: { in: 6..72 }, on: :create
end
