require "rails_helper"

RSpec.describe User, type: :model do
  it "validates login presence" do
    expect(User.new(login: "test")).to be_valid
    expect(User.new(login: nil)).not_to be_valid
  end

  it "validates login uniqueness" do
    User.create!(login: "test")
    expect(User.new(login: "test")).not_to be_valid
  end
end
