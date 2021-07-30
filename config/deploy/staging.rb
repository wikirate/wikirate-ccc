set :stage,  :staging
set :branch, "develop"
set :deploy_to, '/srv/staging_ccc'

role :app, %w{johannes}
role :web, %w{johannes}
role :db,  %w{johannes}

server 'johannes', user: 'deploy'
