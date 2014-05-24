# This is a sample Capistrano config file for rubber
# Execute "bundle install" after deploy, but only when really needed
require "bundler/capistrano"
require 'thinking_sphinx/capistrano'
require 'whenever/capistrano'
require 'rvm/capistrano'
require 'delayed/recipes'
# require 'capistrano/ext/multistage'
# require 'capistrano/maintenance'

# set stages
#set :stages, %w(production staging)
#set :default_stage, "production"

# Automatically precompile assets
load "deploy/assets"

set :rails_env, Rubber.env
default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}
# ssh_options[:keys] = %w(~/.ec2/pixi-prod01.pem)
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "deploy")]

on :load do
  set :application, rubber_env.app_name
  set :runner,      rubber_env.app_user
  set :deploy_to,   "/mnt/#{application}-#{Rubber.env}"
  set :copy_exclude, [".git/*", ".bundle/*", "log/*", ".rvmrc", ".rbenv-version"]
  set :assets_role, [:app]
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
set :rvm_ruby_string, '1.9.3-p484'

# Easier to do system level config as root - probably should do it through
# sudo in the future.  We use ssh keys for access, so no passwd needed
# set :user, 'ec2-user'
set :user, 'root'
set :password, nil

# Use sudo with user rails for cap deploy:[stop|start|restart]
# This way exposed services (mongrel) aren't running as a privileged user
set :use_sudo, false

# How many old releases should be kept around when running "cleanup" task
set :keep_releases, 3

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
    run "chmod +x #{current_path}/script/rubber && chmod +x #{release_path}/script/rubber"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/pixi_keys.yml #{release_path}/config/pixi_keys.yml"    
    run "ln -nfs #{shared_path}/config/api_keys.yml #{release_path}/config/api_keys.yml"    
    run "ln -nfs #{shared_path}/config/aws.yml #{release_path}/config/aws.yml"    
    run "ln -nfs #{shared_path}/config/gateway.yml #{release_path}/config/gateway.yml"    
    run "ln -nfs #{shared_path}/config/sendmail.yml #{release_path}/config/sendmail.yml"    
    run "ln -nfs #{shared_path}/config/thinking_sphinx.yml #{release_path}/config/thinking_sphinx.yml"    
  end 
end

  namespace :sphinx do
    desc 'create sphinx directory'
    task :create_sphinx_dir, :roles => :app do
      run "mkdir -p #{shared_path}/sphinx"
    end
   
    desc "Stop the sphinx server"
    task :stop, :roles => :app do
      unless :previous_release
        run "cd #{previous_release} && RAILS_ENV=#{rails_env} rake thinking_sphinx:stop"
      end
    end

    desc "Reindex the sphinx server"
    task :index, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake thinking_sphinx:index"
    end

    desc "Configure the sphinx server"
    task :configure, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake thinking_sphinx:configure"
    end

    desc "Start the sphinx server"
    task :start, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake thinking_sphinx:start"
    end

    desc "Rebuild the sphinx server"
    task :rebuild, :roles => :app do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake thinking_sphinx:rebuild"
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

namespace :deploy do
  namespace :web do
    desc "Enable maintenance mode for apache"
    task :disable, :roles => :web do
      on_rollback { run "rm -f #{shared_path}/system/maintenance.html" }
      page = File.read('public/maintenance.html')
      put page, "#{shared_path}/system/maintenance.html", :mode => 0644
    end

    desc "Disable maintenance mode for apache"
    task :enable, :roles => :web do
      run "rm -f #{shared_path}/system/maintenance.html"
    end
  end
end

# load in the deploy scripts installed by vulcanize for each rubber module
Dir["#{File.dirname(__FILE__)}/rubber/deploy-*.rb"].each do |deploy_file|
  load deploy_file
end

# capistrano's deploy:cleanup doesn't play well with FILTER
before 'deploy:setup', 'sphinx:create_sphinx_dir'
before 'deploy:update_code', 'deploy:enable_rubber'
after 'deploy:update_code', 'deploy:symlink_shared', 'sphinx:stop'
after "deploy", "cleanup"
after "deploy:migrations", "cleanup", "sphinx:sphinx_symlink", "sphinx:configure", "sphinx:rebuild"
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
  before "deploy:assets:precompile", "deploy:assets:symlink"
  after "rubber:config", "deploy:assets:precompile"
end

# Delayed Job  
after "deploy:stop",    "delayed_job:stop"  
after "deploy:start",   "delayed_job:start"  
after "deploy:restart", "delayed_job:restart", "deploy:cleanup"
