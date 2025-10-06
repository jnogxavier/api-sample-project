require "rails_helper"

RSpec.describe Post, type: :model do
  let(:user) { User.create!(login: "testuser") }

  it "validates required fields" do
    expect(Post.new(title: "Test", body: "Body", ip: "1.1.1.1", user: user)).to be_valid
    expect(Post.new(title: nil, body: "Body", ip: "1.1.1.1", user: user)).not_to be_valid
    expect(Post.new(title: "Test", body: nil, ip: "1.1.1.1", user: user)).not_to be_valid
    expect(Post.new(title: "Test", body: "Body", ip: nil, user: user)).not_to be_valid
  end

  describe "#average_rating" do
    let(:post) { Post.create!(title: "Test", body: "Body", ip: "1.1.1.1", user: user) }

    it "calculates average" do
      expect(post.average_rating).to eq(0)

      user2 = User.create!(login: "user2")
      Rating.create!(post: post, user: user2, value: 4)
      expect(post.average_rating).to eq(4.0)

      user3 = User.create!(login: "user3")
      Rating.create!(post: post, user: user3, value: 5)
      expect(post.average_rating).to eq(4.5)
    end
  end
end
