require "json"
require "net/http"
require "uri"

puts "Seeding database..."

BASE_URL = "http://localhost:3000"
USERS = 100.times.map { |i| "user_#{i.to_s.rjust(3, '0')}" }

def make_request(method, path, data = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)

  case method
  when :post
    request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
    request.body = data.to_json if data
  when :get
    request = Net::HTTP::Get.new(uri.path)
  end

  response = http.request(request)
  JSON.parse(response.body) if response.body
rescue StandardError => e
  puts "Error making request: #{e.message}"
  nil
end

puts "Creating posts..."
post_ids = []
batch_size = 1000

(200_000 / batch_size).times do |batch|
  batch_size.times do |i|
    post_data = {
      post: {
        title: "Sample Post #{batch * batch_size + i + 1}",
        body: "Post content #{batch * batch_size + i + 1}",
        login: USERS.sample
      }
    }

    response = make_request(:post, "/api/posts", post_data)
    post_ids << response["post"]["id"] if response && response["post"]
  end

  puts "#{post_ids.size} posts created" if (batch + 1) % 10 == 0
end

puts "Creating ratings..."
all_users = User.pluck(:id, :login)
posts_to_rate = (post_ids.size * 0.75).to_i
ratings_count = 0

posts_to_rate.times do |i|
  rated_users = all_users.sample(rand(1..5))

  rated_users.each do |user_id, _|
    rating_data = {
      rating: {
        post_id: post_ids[i],
        user_id: user_id,
        value: rand(1..5)
      }
    }

    response = make_request(:post, "/api/ratings", rating_data)
    ratings_count += 1 if response && response["average_rating"]
  end

  puts "#{i + 1} posts rated" if (i + 1) % 10000 == 0
end

puts "\nDone: #{post_ids.size} posts, #{all_users.size} users, #{ratings_count} ratings"
