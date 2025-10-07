module Api
  class PostsController < ApplicationController
    include ErrorHandler

    def create
      service = Posts::Creator.new(
        title: post_params[:title],
        body: post_params[:body],
        login: post_params[:login],
        ip_address: client_ip
      ).call

      if service.success?
        render json: PostSerializer.new(service.post).as_json, status: :created
      else
        render_validation_errors(service.errors)
      end
    end

    def top
      posts = Posts::TopRatedQuery.new(limit: params[:limit]).call
      render json: posts.map { |p| { id: p.id, title: p.title, body: p.body } }
    end

    private

    def post_params
      params.require(:post).permit(:title, :body, :login)
    end

    def client_ip
      request.headers["X-Forwarded-For"] || request.remote_ip
    end
  end
end
