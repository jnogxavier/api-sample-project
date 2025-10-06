class AddIndexesToPosts < ActiveRecord::Migration[8.0]
  def change
    add_index :posts, :ip
    add_index :posts, :created_at
  end
end
