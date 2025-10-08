require "rails_helper"

RSpec.describe User, type: :model do
  it "validates login presence" do
    expect(User.new(login: "test")).to be_valid
    expect(User.new(login: nil)).not_to be_valid
  end

  it "validates login uniqueness" do
    User.create!(login: "test")
    duplicate_user = User.new(login: "test")
    expect { duplicate_user.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
