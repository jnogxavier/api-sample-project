
module Posts
  class Creator
    attr_reader :title, :body, :login, :ip_address, :post, :errors

    def initialize(title:, body:, login:, ip_address:)
      @title = title
      @body = body
      @login = login
      @ip_address = ip_address
      @errors = []
    end

    def call
      find_or_create_user
      create_post if @user
      self
    end

    def success?
      errors.empty? && post.present?
    end

    private

    def find_or_create_user
      @user = User.find_or_create_by(login: login)
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
    end

    def create_post
      @post = @user.posts.create(
        title: title,
        body: body,
        ip: ip_address
      )
      @errors = @post.errors.full_messages unless @post.persisted?
    end
  end
end
