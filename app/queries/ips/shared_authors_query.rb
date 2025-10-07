
module Ips
  class SharedAuthorsQuery
    def call
      Post
        .select("posts.ip, ARRAY_AGG(DISTINCT users.login) as authors")
        .joins(:user)
        .group("posts.ip")
        .having("COUNT(DISTINCT posts.user_id) > 1")
        .order("posts.ip")
    end

    def as_json
      call.map do |record|
        {
          ip: record.ip,
          authors: record.authors
        }
      end
    end
  end
end
