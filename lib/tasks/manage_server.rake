namespace :manage_server do

  task :reset_users => :environment do
    User.destroy_all
  end
end

