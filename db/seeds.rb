require "json"
require "net/http"
require "uri"

puts "Seeding database..."

BASE_URL = "http://localhost:3000"
USERS = 100.times.map { |i| "user_#{i.to_s.rjust(3, '0')}" }
IPS = 50.times.map { |i| "192.168.#{i / 256}.#{i % 256}" }
THREAD_POOL_SIZE = 20

def make_request(method, path, data = nil, ip = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)

  case method
  when :post
    request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
    request["X-Forwarded-For"] = ip if ip
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
post_ids_mutex = Mutex.new
batch_size = 1000
start_time = Time.now

(200_000 / batch_size).times do |batch|
  threads = []

  batch_size.times.each_slice(THREAD_POOL_SIZE) do |slice|
    slice.each do |i|
      threads << Thread.new do
        post_data = {
          post: {
            title: "Sample Post #{batch * batch_size + i + 1}",
            body: "Post content #{batch * batch_size + i + 1}",
            login: USERS.sample
          }
        }

        response = make_request(:post, "/api/posts", post_data, IPS.sample)
        if response && response["post"]
          post_ids_mutex.synchronize { post_ids << response["post"]["id"] }
        end
      end
    end

    threads.each(&:join)
    threads.clear
  end

  elapsed = Time.now - start_time
  puts "#{post_ids.size} posts created (#{elapsed.round(2)}s)"
end

posts_elapsed = Time.now - start_time
puts "Posts created in #{posts_elapsed.round(2)} seconds"

puts "Creating ratings..."
all_users = User.pluck(:id, :login)
posts_to_rate = (post_ids.size * 0.75).to_i
ratings_count = 0
ratings_count_mutex = Mutex.new
ratings_start_time = Time.now

posts_to_rate.times.each_slice(100) do |batch_indices|
  threads = []

  batch_indices.each do |i|
    threads << Thread.new do
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
        if response && response["average_rating"]
          ratings_count_mutex.synchronize { ratings_count += 1 }
        end
      end
    end

    if threads.size >= THREAD_POOL_SIZE
      threads.each(&:join)
      threads.clear
    end
  end

  threads.each(&:join)
  if (batch_indices.last + 1) % 10000 == 0
    elapsed = Time.now - ratings_start_time
    puts "#{ratings_count} ratings created (#{elapsed.round(2)}s)"
  end
end

ratings_elapsed = Time.now - ratings_start_time
puts "Ratings created in #{ratings_elapsed.round(2)} seconds"

total_elapsed = posts_elapsed + ratings_elapsed
puts "\nDone: #{post_ids.size} posts, #{all_users.size} users, #{ratings_count} ratings"
puts "Total time: #{total_elapsed.round(2)} seconds"
