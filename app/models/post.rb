class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, :body, :ip, presence: true

  def average_rating
    ratings.average(:value)&.round(2) || 0
  end
end
