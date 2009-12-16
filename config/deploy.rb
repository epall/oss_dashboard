set :application, "rcos_dashboard"
set :deploy_to, "/usr/local/www/rcos_dashboard"

set :scm, :git
set :repository, "git://github.com/epall/oss_dashboard.git"
set :branch, "rcos"
set :deploy_via, :remote_cache

set :user, 'epall'

role :app, "128.213.32.124"
role :web, "128.213.32.124"
role :db, "128.213.32.124", :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end
