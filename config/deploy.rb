# Execute "bundle install" after deploy, but only when really needed
require "bundler/capistrano"
require 'thinking_sphinx/capistrano'
require 'whenever/capistrano'
require 'rvm/capistrano'
require 'delayed/recipes'
# require 'capistrano/ext/multistage'
require 'capistrano/maintenance'

# Automatically precompile assets
set :assets_role, [:app, :worker]
load "deploy/assets"

# set stages
set :stages, %w(production staging)
set :default_stage, "production"

set :rails_env, Rubber.env
set :rails_root, '/var/www/html/pixiboard/staging/plumboard'
default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}
# ssh_options[:keys] = %w(~/.ec2/pixi-prod01.pem)
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "deploy")]

on :load do
  set :application, rubber_env.app_name
  set :runner,      rubber_env.app_user
  set :deploy_to,   "/mnt/#{application}-#{Rubber.env}"
  set :copy_exclude, [".git/*", ".bundle/*", "log/*", ".rvmrc", ".rbenv-version"]
end

# Use a simple directory tree copy here to make demo easier.
# You probably want to use your own repository for a real app
set :repository, "git@github.com:sdbmich1/plumboard.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :copy

# System-wide RVM installation
set :rvm_type, :system

# Target ruby version
#set :rvm_ruby_string, '1.9.3-p484'
#set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment
#set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

# Easier to do system level config as root - probably should do it through
# sudo in the future.  We use ssh keys for access, so no passwd needed
# set :user, 'ec2-user'
set :user, 'root'
set :password, nil

# Use sudo with user rails for cap deploy:[stop|start|restart]
# This way exposed services (mongrel) aren't running as a privileged user
set :use_sudo, false

# How many old releases should be kept around when running "cleanup" task
set :keep_releases, 5

# Lets us work with staging instances without having to checkin config files
# (instance*.yml + rubber*.yml) for a deploy.  This gives us the
# convenience of not having to checkin files for staging, as well as 
# the safety of forcing it to be checked in for production.
# set :push_instance_config, Rubber.env != 'production'
set :push_instance_config, true

# don't waste time bundling gems that don't need to be there 
set :bundle_without, [:development, :test, :staging] if Rubber.env == 'production'

# set whenever command
set :whenever_command, "bundle exec whenever"
set :whenever_roles, :app 

# set delayed job settings
# set :delayed_job_server_role, :worker
set :delayed_job_args, "-n 2"

# Allow us to do N hosts at a time for all tasks - useful when trying
# to figure out which host in a large set is down:
# RUBBER_ENV=production MAX_HOSTS=1 cap invoke COMMAND=hostname
max_hosts = ENV['MAX_HOSTS'].to_i
default_run_options[:max_hosts] = max_hosts if max_hosts > 0

# Allows the tasks defined to fail gracefully if there are no hosts for them.
# Comment out or use "required_task" for default cap behavior of a hard failure
rubber.allow_optional_tasks(self)

# Wrap tasks in the deploy namespace that have roles so that we can use FILTER
# with something like a deploy:cold which tries to run deploy:migrate but can't
# because we filtered out the :db role
namespace :deploy do
  rubber.allow_optional_tasks(self)
  tasks.values.each do |t|
    if t.options[:roles]
      task t.name, t.options, &t.body
    end
  end
  
  desc "Enable rubber scripts"
  task :enable_rubber do
    puts "\n\n=== Enabling rubber scripts! ===\n\n"
    run "chmod +x #{release_path}/script/rubber"
  end

  task :enable_rubber_current do
    puts "\n\n=== Enabling rubber current scripts! ===\n\n"
    # run "ln -nfs #{release_path}/script/rubber #{current_path}/script/rubber"
    # run "chmod +x #{current_path}/script/rubber "
    run "ln -nfs #{shared_path}/config/rubber/common/database.yml #{release_path}/config/rubber/common/database.yml"
    run "touch #{current_path}/log/production.log"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/rubber/common/database.yml #{release_path}/config/rubber/common/database.yml"
    # run "ln -nfs #{shared_path}/public/assets/manifest.yml #{release_path}/assets_manifest.yml"    
    run "chmod +x #{release_path}/script/rubber"
  end 
end

  namespace :sphinx do
    desc 'create sphinx directory'
    task :create_sphinx_dir, :roles => :app do
      run "mkdir -p #{shared_path}/db/sphinx && mkdir -p #{shared_path}/tmp"
    end

    desc 'Symlink Sphinx indexes from the shared folder to the latest release.'
    task :symlink_indexes, :roles => :app do
      run "if [ -d #{release_path} ]; then ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx; else ln -nfs #{shared_path}/db/sphinx #{current_path}/db/sphinx; fi;"
    end
   
    desc "Stop the sphinx server"
    task :stop, :roles => :app do
      unless :previous_release
        run "cd #{previous_release} && RAILS_ENV=#{rails_env} SPHINX_VERSION=2.0.8 rake ts:stop"
      end
    end

    desc "Reindex the sphinx server"
    task :index, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} SPHINX_VERSION=2.0.8 rake ts:index"
    end

    desc "Configure the sphinx server"
    task :configure, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} SPHINX_VERSION=2.0.8 rake ts:configure"
    end

    desc "Start the sphinx server"
    task :start, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} SPHINX_VERSION=2.0.8 rake ts:start"
    end

    desc "Rebuild the sphinx server"
    task :rebuild, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} SPHINX_VERSION=2.0.8 rake ts:rebuild"
    end    
  end

namespace :deploy do
  namespace :assets do
    rubber.allow_optional_tasks(self)
    tasks.values.each do |t|
      if t.options[:roles]
        task t.name, t.options, &t.body
      end
    end
  end
end

namespace :files do
  puts "\n\n=== Uploading secret files! ===\n\n"
  task :upload_secret do
    upload("#{rails_root}/config/aws.yml", "#{release_path}/config/aws.yml", :via => :scp)
    upload("#{rails_root}/config/api_keys.yml", "#{release_path}/config/api_keys.yml")
    upload("#{rails_root}/config/pixi_keys.yml", "#{release_path}/config/pixi_keys.yml")
    upload("#{rails_root}/config/gateway.yml", "#{release_path}/config/gateway.yml")
    upload("#{rails_root}/config/sendmail.yml", "#{release_path}/config/sendmail.yml")
    upload("#{rails_root}/config/thinking_sphinx.yml", "#{release_path}/config/thinking_sphinx.yml")
    upload("#{rails_root}/config/database.yml", "#{release_path}/config/database.yml")
  end

  task :upload_certs do
    upload("#{rails_root}/config/certs/pixiboard.crt", "#{release_path}/config/pixiboard.crt")
    upload("#{rails_root}/config/certs/pixiboard.key", "#{release_path}/config/pixiboard.key")
    upload("#{rails_root}/config/certs/gd_bundle.crt", "#{release_path}/config/gd_bundle.crt")
    run "touch #{current_path}/public/httpchk.txt"
  end
end

namespace :memcached do
  desc "Flushes memcached local instance"
  task :flush, :roles => [:app] do
    # run("cd #{current_path} && rake memcached:flush")
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake memcached:flush"
  end
end

namespace :whenever do    
  desc "Update the crontab file for the Whenever Gem."
  task :update_crontab, :roles => [:app] do
    puts "\n\n=== Updating the Crontab! ===\n\n"
    run "cd #{release_path} && #{whenever_command} --update-crontab #{application}" 
  end    
end

namespace :pxb do    
  desc "Update the PXB server data."
  task :update_server, :roles => [:app] do
    puts "\n\n=== Updating the Server Database! ===\n\n"
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake manage_server:run_update_tasks"
  end    
end

# load in the deploy scripts installed by vulcanize for each rubber module
Dir["#{File.dirname(__FILE__)}/rubber/deploy-*.rb"].each do |deploy_file|
  load deploy_file
end

# capistrano's deploy:cleanup doesn't play well with FILTER
#before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
#before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset
before 'deploy:setup', 'sphinx:create_sphinx_dir'
before 'rubber:config', 'deploy:enable_rubber', 'deploy:enable_rubber_current'
after 'bundle:install', 'deploy:enable_rubber'
after 'deploy:update_code', 'deploy:enable_rubber'
after 'deploy:update_code', 'deploy:symlink_shared', 'sphinx:stop'
#after "deploy:migrations", "cleanup"
after "deploy", "cleanup", "memcached:flush"
after "deploy:update", "deploy:migrations"

task :cleanup, :except => { :no_release => true } do
  count = fetch(:keep_releases, 5).to_i
  rsudo <<-CMD
    all=$(ls -x1 #{releases_path} | sort -n);
    keep=$(ls -x1 #{releases_path} | sort -n | tail -n #{count});
    remove=$(comm -23 <(echo -e "$all") <(echo -e "$keep"));
    for r in $remove; do rm -rf #{releases_path}/$r; done;
  CMD
end

# We need to ensure that rubber:config runs before asset precompilation in Rails, as Rails tries to boot the environment,
# which means needing to have DB access.  However, if rubber:config hasn't run yet, then the DB config will not have
# been generated yet.  Rails will fail to boot, asset precompilation will fail to complete, and the deploy will abort.
if Rubber::Util.has_asset_pipeline?
  load 'deploy/assets'

  callbacks[:after].delete_if {|c| c.source == "deploy:assets:precompile"}
  callbacks[:before].delete_if {|c| c.source == "deploy:assets:symlink"}
  before "deploy:assets:precompile", "deploy:assets:symlink", "files:upload_secret", "files:upload_certs"
  after "rubber:config", "deploy:assets:precompile"
end

# Delayed Job  
after "deploy:stop",    "delayed_job:stop"  
after "deploy:start",   "delayed_job:start", "whenever:update_crontab", "pxb:update_server"  
after "deploy:restart"
