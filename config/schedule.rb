# Use this file to easily define all of your cron jobs.
#
# setup output files
set :output, {:error => 'cron_error.log', :standard => 'cron.log'}

# rebuild sphinx every 30 minutes
every "0,30 * * * *", :roles => [:app] do
  rake "ts:index"
end

# clear cache every day
every "30 2 * * *", :roles => [:app] do
  rake "memcached:flush"
end

# expire pixis every day
every "30 3 * * *", :roles => [:app] do
  rake "manage_server:close_expired_pixis"
end

# run every sunday
every "30 3 * * 0", :roles => [:app] do
  rake "manage_server:cleanup_guests"
end
