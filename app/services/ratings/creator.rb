
module Ratings
  class Creator
    attr_reader :post_id, :user_id, :value, :rating, :errors, :average_rating

    def initialize(post_id:, user_id:, value:)
      @post_id = post_id
      @user_id = user_id
      @value = value
      @errors = []
    end

    def call
      create_rating
      calculate_average if @rating&.persisted?
      self
    end

    def success?
      errors.empty? && rating.present?
    end

    private

    def create_rating
      @rating = Rating.new(post_id: post_id, user_id: user_id, value: value)
      @rating.save
      @errors = @rating.errors.full_messages unless @rating.persisted?
    rescue ActiveRecord::RecordNotUnique
      @errors << "User has already rated this post"
    end

    def calculate_average
      @average_rating = @rating.post.ratings.average(:value).round(2)
    end
  end
end
