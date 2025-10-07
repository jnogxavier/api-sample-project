
class PostSerializer
  attr_reader :post

  def initialize(post)
    @post = post
  end

  def as_json
    {
      post: {
        id: post.id,
        title: post.title,
        body: post.body,
        ip: post.ip,
        created_at: post.created_at,
        user: UserSerializer.new(post.user).as_json
      }
    }
  end
end
