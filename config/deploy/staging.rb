set :user, "ec2-user"
server "ec2-54-215-166-109.us-west-1.compute.amazonaws.com", :app, :web, :db, :primary => true
set :rails_env, "staging"
set :deploy_to, "/var/www/html/#{application}/#{rails_env}"
ssh_options[:keys] = ["c:/RoRDev/pixi01.pem"]
set :bundle_without, [:test, :development]
