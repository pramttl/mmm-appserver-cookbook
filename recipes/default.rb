#
# Cookbook Name:: mmm-appserver
# Recipe:: default
#
# Copyright (C) 2015 Pranjal Mittal
#
# All rights reserved - Do Not Redistribute
#


include_recipe "apt"
include_recipe 'python'
include_recipe "python::pip"

username = 'vagrant'

bash 'update_apt_index' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  apt-get update
  EOH
end

# Install the nginx package
apt_package 'git' do
  action :install
end

# Add nginx source to apt sources
apt_repository 'nginx' do
  uri          'http://nginx.org/packages/ubuntu/'
  distribution node['lsb']['codename']
  components   ['nginx']
  key          'http://nginx.org/keys/nginx_signing.key'
  deb_src      true
end

# Install the nginx package
apt_package 'nginx' do
  action :install
end

# Install the nginx package
apt_package 'postgresql' do
  action :install
end

# Install the nginx package
apt_package 'python-dev' do
  action :install
end

# Install the nginx package
apt_package 'libpq-dev' do
  action :install
end

directory "/etc/nginx/sites-available/" do
  action :create
end

directory "/etc/nginx/sites-enabled/" do
  action :create
end

# Adding MMM site
cookbook_file "/etc/nginx/sites-available/makemymails" do
   source "nginx_mmm_site.conf"
   path "/etc/nginx/sites-available/default"
   action :create
end


# Telling Nginx to set MMM site as enabled
link "/etc/nginx/sites-enabled/makemymails" do
  to "/etc/nginx/sites-available/makemymails"
end

# Inistall pypi package virtualenv, rest of the deps are installed from the requirements.txt file
python_pip "virtualenv" do
  action :install
end

# Sync git repository (clones if it does not exist)
git "/home/#{username}/makemymails" do
  repository "https://bitbucket.org/pramttl/makemymails"
  checkout_branch "develop"
  action :sync
end

python_virtualenv "/home/#{username}/makemymails/venv" do
  interpreter "python2.7"
  action :create
end

bash 'install_python_requirements' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  cd /home/#{username}/makemymails
  source venv/bin/activate
  pip install -r requirements.txt
  pip install -r prod_requirements.txt
  EOH
end

bash 'migrate_schema_start_server' do
  user 'root'
  code <<-EOH
  cd /home/#{username}/makemymails
  if [ ! -d "$DIRECTORY" ]; then
    virtualenv venv
  fi
  python manage.py migrate
  if [ -f /tmp/gunicorn.pid ]; then
    kill -9 $(cat /tmp/gunicorn.pid)
  fi
  gunicorn makemymails.wsgi:application --bind 127.0.0.1:8000 --pid /tmp/gunicorn.pid --daemon
  EOH
end

# Start gunicorn first
service 'nginx' do
  action [ :enable, :start ]
end
