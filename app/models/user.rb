class User < ApplicationRecord
  validates :name, presence: true, length: {minimum: 1}
  validates :email, presence: true, length: {minimum: 1}
  validates :password, presence: true, length: {minimum: 6}
end
