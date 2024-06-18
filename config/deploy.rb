# frozen_string_literal: true

set :application, 'rizz'
set :repo_url, 'https://github.com/sul-dlss-labs/rizz.git'

# Default branch is :main
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/opt/app/rizz/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :linked_dirs, %w[log tmp/pids tmp/cache tmp/file-cache tmp/sockets]
# set :linked_files, %w[config/honeybadger.yml config/database.yml]

set :passenger_roles, :web
set :rails_env, 'production'

# See https://github.com/capistrano/rails/issues/257
set :assets_manifests, lambda {
  [release_path.join('public', fetch(:assets_prefix), '.manifest.json')]
}

# Run db migrations on app servers, not db server
# set :migration_role, :app

# honeybadger_env otherwise defaults to rails_env
# set :honeybadger_env, fetch(:stage)

# update shared_configs before restarting app
# before 'deploy:restart', 'shared_configs:update'

# For now, clearing cache on deploy
task :clear_cache do
  on roles(:app) do
    within current_path do
      with rails_env: fetch(:rails_env) do
        rake 'cache:clear'
      end
    end
  end
end
after 'deploy:published', 'clear_cache'
