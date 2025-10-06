class User < ApplicationRecord
  has_many :posts
  has_many :ratings

  validates :login, presence: true, uniqueness: true
end
