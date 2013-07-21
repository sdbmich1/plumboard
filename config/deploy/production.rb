set :user, "ec2-user"
server "ec2-54-215-161-238.us-west-1.compute.amazonaws.com", :app, :web, :db, :primary => true
set :rails_env, "production"
set :deploy_to, "/var/www/html/#{application}/#{rails_env}"
ssh_options[:keys] = ["c:/RoRDev/pixi-prod01.pem"]

set :rvm_ruby_string, :local
set :bundle_without, [:test, :development, :staging]
