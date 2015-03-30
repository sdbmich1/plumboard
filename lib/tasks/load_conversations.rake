task :map_posts_to_conversations => :environment do
  Post.map_posts_to_conversations
end

task :set_updt_date => :environment do
  set_updated_date
end

def set_updated_date
  Conversation.find_each do |c|
    post = c.posts.reorder('posts.created_at DESC').first
    c.update_attribute(:updated_at, post.created_at) if post
  end
end
