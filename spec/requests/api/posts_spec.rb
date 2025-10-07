require "rails_helper"

RSpec.describe "Api::Posts", type: :request do
  describe "POST /api/posts" do
    let(:params) do
      {
        post: {
          title: "Sample Post",
          body: "Post body",
          login: "testuser"
        }
      }
    end

    it "creates user and post" do
      expect {
        post "/api/posts", params: params, as: :json
      }.to change(User, :count).by(1).and change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["post"]["title"]).to eq("Sample Post")
      expect(json["post"]["user"]["login"]).to eq("testuser")
      expect(json["post"]["ip"]).to eq("127.0.0.1")
    end

    it "reuses existing user" do
      user = User.create!(login: "testuser")

      expect {
        post "/api/posts", params: params, as: :json
      }.to change(Post, :count).by(1).and change(User, :count).by(0)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["post"]["user"]["id"]).to eq(user.id)
    end

    it "returns errors on invalid data" do
      post "/api/posts", params: { post: { title: "", body: "", login: "testuser" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "GET /api/posts/top" do
    let!(:user1) { User.create!(login: "user1") }
    let!(:user2) { User.create!(login: "user2") }
    let!(:post1) { Post.create!(title: "Post 1", body: "Body 1", ip: "1.1.1.1", user: user1) }
    let!(:post2) { Post.create!(title: "Post 2", body: "Body 2", ip: "1.1.1.2", user: user1) }
    let!(:post3) { Post.create!(title: "Post 3", body: "Body 3", ip: "1.1.1.3", user: user2) }

    before do
      Rating.create!(post: post1, user: user2, value: 5)
      Rating.create!(post: post2, user: user2, value: 3)
      Rating.create!(post: post3, user: user1, value: 4)
    end

    it "orders by rating" do
      get "/api/posts/top", params: { limit: 10 }

      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json[0]["id"]).to eq(post1.id)
      expect(json[1]["id"]).to eq(post3.id)
      expect(json[2]["id"]).to eq(post2.id)
    end

    it "respects limit" do
      get "/api/posts/top", params: { limit: 2 }
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "uses default limit" do
      15.times do |i|
        p = Post.create!(title: "Post #{i}", body: "Body #{i}", ip: "1.1.1.#{i}", user: user1)
        Rating.create!(post: p, user: user2, value: 3)
      end

      get "/api/posts/top"
      expect(JSON.parse(response.body).length).to eq(10)
    end
  end
end
