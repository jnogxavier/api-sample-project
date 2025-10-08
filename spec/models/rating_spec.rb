require "rails_helper"

RSpec.describe Rating, type: :model do
  let(:user) { User.create!(login: "testuser") }
  let(:post) { Post.create!(title: "Test", body: "Body", ip: "1.1.1.1", user: user) }
  let(:rater) { User.create!(login: "rater") }

  it "validates value" do
    expect(Rating.new(post: post, user: rater, value: 5)).to be_valid
    expect(Rating.new(post: post, user: rater, value: nil)).not_to be_valid
    expect(Rating.new(post: post, user: rater, value: 0)).not_to be_valid
    expect(Rating.new(post: post, user: rater, value: 6)).not_to be_valid
  end

  it "prevents duplicate user ratings" do
    Rating.create!(post: post, user: rater, value: 5)
    duplicate_rating = Rating.new(post: post, user: rater, value: 4)
    expect { duplicate_rating.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
