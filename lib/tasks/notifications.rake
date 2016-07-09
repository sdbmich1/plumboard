namespace :msg do
  # Send a message to each active follower after a store they are following
  # has posted one or more new pixis in the past day
  task :send_favorite_store_notices => :environment do
    stores = User.joins(:listings).where("listings.created_at >= ? && users.user_type_code = 'BUS'", Time.zone.now - 1.days).uniq
    stores.each do |store|
      follower_ids = FavoriteSeller.where(seller_id: store.id, status: 'active').pluck(:user_id)
      devices = Device.where(user_id: follower_ids).pluck(:token)
      next if devices.empty?
      message = "#{store.business_name} has new items for you",
      Resque.enqueue(NotificationSender, message, devices, {})
    end
  end
end
