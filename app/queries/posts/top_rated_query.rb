module Posts
  class TopRatedQuery
    DEFAULT_LIMIT = 10

    def initialize(limit: DEFAULT_LIMIT)
      @limit = limit.to_i.positive? ? limit.to_i : DEFAULT_LIMIT
    end

    def call
      Post.select("posts.*, AVG(ratings.value) as avg_rating")
          .joins(:ratings)
          .group("posts.id")
          .order("avg_rating DESC")
          .limit(@limit)
    end
  end
end
