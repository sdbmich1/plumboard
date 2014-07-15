namespace :load_conversations do

    task :map_posts_to_conversations => :environment do
      Post.map_posts_to_conversations
    end

end
