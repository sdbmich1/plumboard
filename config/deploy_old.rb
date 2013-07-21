$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Execute "bundle install" after deploy, but only when really needed
require "bundler/capistrano"

# RVM integration
require "rvm/capistrano"
require 'capistrano/ext/multistage'
require "whenever/capistrano"
require 'thinking_sphinx/deploy/capistrano'

# Automatically precompile assets
load "deploy/assets"

# System-wide RVM installation
set :rvm_type, :system

set :stages, %w(production staging)
set :default_stage, "staging"

set :application, "pixiboard"
set :repository, "git@github.com:sdbmich1/plumboard.git"
set :scm, :git
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false

# Target ruby version
set :rvm_ruby_string, '1.9.3-p448'

# use sudo (root) for system-wide RVM installation
set :rvm_install_with_sudo, true

set :deploy_via, :remote_cache

before "deploy", "check_production"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :set_rvm_version, :roles => :app, :except => { :no_release => true } do
    run "source /etc/profile.d/rvm.sh && rvm use #{rvm_ruby_string} --default"
  end

  # Precompile assets only when needed
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do

      # If this is our first deploy - don't check for the previous version
      if remote_file_exists?(current_path)
        from = source.next_revision(current_revision)
        if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
	  run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets_recompile}
	else
	  logger.info "Skipping asset pre-compilation because there were no asset changes"
	end
      else
	run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets_recompile}
      end
    end
  end

  desc "check production task"
  task :check_production do

    if stage.to_s == "production"
      puts " \n Are you REALLY sure you want to deploy to production?"
      puts " \n Enter the password to continue\n "
      password = STDIN.gets[0..7] rescue nil

      if password != 'mypasswd'
        puts "\n !!! WRONG PASSWORD !!!"
        exit
      end
    end
  end
end

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
