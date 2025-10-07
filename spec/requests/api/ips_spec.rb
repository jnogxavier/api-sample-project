require "rails_helper"

RSpec.describe "Api::Ips", type: :request do
  describe "GET /api/ips/shared_authors" do
    let!(:user1) { User.create!(login: "alice") }
    let!(:user2) { User.create!(login: "bob") }
    let!(:user3) { User.create!(login: "charlie") }

    context "when IPs have posts from multiple authors" do
      before do
        # IP 1.1.1.1 has posts from alice and bob
        Post.create!(title: "Post 1", body: "Body 1", ip: "1.1.1.1", user: user1)
        Post.create!(title: "Post 2", body: "Body 2", ip: "1.1.1.1", user: user2)

        # IP 2.2.2.2 has posts from bob and charlie
        Post.create!(title: "Post 3", body: "Body 3", ip: "2.2.2.2", user: user2)
        Post.create!(title: "Post 4", body: "Body 4", ip: "2.2.2.2", user: user3)

        # IP 3.3.3.3 has posts from only alice (should not be included)
        Post.create!(title: "Post 5", body: "Body 5", ip: "3.3.3.3", user: user1)
      end

      it "returns IPs shared by multiple authors" do
        get "/api/ips/shared_authors"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json.length).to eq(2)

        ip1 = json.find { |item| item["ip"] == "1.1.1.1" }
        expect(ip1["authors"]).to match_array([ "alice", "bob" ])

        ip2 = json.find { |item| item["ip"] == "2.2.2.2" }
        expect(ip2["authors"]).to match_array([ "bob", "charlie" ])
      end
    end

    context "when no IPs are shared" do
      before do
        Post.create!(title: "Post 1", body: "Body 1", ip: "1.1.1.1", user: user1)
        Post.create!(title: "Post 2", body: "Body 2", ip: "2.2.2.2", user: user2)
      end

      it "returns an empty array" do
        get "/api/ips/shared_authors"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json).to be_empty
      end
    end

    context "when an IP has posts from three authors" do
      before do
        Post.create!(title: "Post 1", body: "Body 1", ip: "1.1.1.1", user: user1)
        Post.create!(title: "Post 2", body: "Body 2", ip: "1.1.1.1", user: user2)
        Post.create!(title: "Post 3", body: "Body 3", ip: "1.1.1.1", user: user3)
      end

      it "returns all three authors" do
        get "/api/ips/shared_authors"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json.length).to eq(1)
        expect(json[0]["authors"]).to match_array([ "alice", "bob", "charlie" ])
      end
    end
  end
end
