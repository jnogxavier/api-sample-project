require "rails_helper"

RSpec.describe "Api::Ratings", type: :request do
  let!(:user1) { User.create!(login: "user1") }
  let!(:user2) { User.create!(login: "user2") }
  let!(:post1) { Post.create!(title: "Post 1", body: "Body 1", ip: "1.1.1.1", user: user1) }

  describe "POST /api/ratings" do
    let(:params) do
      { rating: { post_id: post1.id, user_id: user2.id, value: 5 } }
    end

    it "creates rating" do
      expect {
        post "/api/ratings", params: params, as: :json
      }.to change(Rating, :count).by(1)

      json = JSON.parse(response.body)
      expect(json["average_rating"]).to eq("5.0")
    end

    it "calculates average" do
      Rating.create!(post: post1, user: user1, value: 4)
      post "/api/ratings", params: params, as: :json

      json = JSON.parse(response.body)
      expect(json["average_rating"]).to eq("4.5")
    end

    it "prevents duplicate ratings" do
      Rating.create!(post: post1, user: user2, value: 5)

      expect {
        post "/api/ratings", params: params, as: :json
      }.not_to change(Rating, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "validates value range" do
      post "/api/ratings", params: { rating: { post_id: post1.id, user_id: user2.id, value: 6 } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)

      post "/api/ratings", params: { rating: { post_id: post1.id, user_id: user2.id, value: 0 } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
