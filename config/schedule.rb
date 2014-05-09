# Use this file to easily define all of your cron jobs.
#
# setup output files
set :output, {:error => 'error.log', :standard => 'cron.log'}

# rebuild sphinx every 5 minutes
every "0,30 * * * *", :roles => [:app] do
  rake "ts:index"
end
