namespace :manage_server do

  task :reset_users => :environment do
    User.delete_all
  end
end

