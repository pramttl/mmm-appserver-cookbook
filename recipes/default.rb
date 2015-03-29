#
# Cookbook Name:: create
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe "apt"
include_recipe 'python'
include_recipe "python::pip"

apt_repository 'nginx' do
  uri          'http://nginx.org/packages/ubuntu/'
  distribution node['lsb']['codename']
  components   ['nginx']
  key          'http://nginx.org/keys/nginx_signing.key'
  deb_src      true
end

# Deleting the existing default site in nginx
file "/etc/nginx/sites-available/default" do
   action :delete
end

# Adding MMM configuration to the default file
cookbook_file "/etc/nginx/sites-available/default" do
   source "nginx_mmm_site.conf"
   path "/etc/nginx/sites-available/default"
   action :create
end

# Telling Nginx to set MMM site as enabled
link "/etc/nginx/sites-available/default" do
  to "/etc/nginx/sites-enabled/default"
end

python_pip "virtualenv" do
  action :install
end

# Start gunicorn first

service 'nginx' do
  action [ :enable, :start ]
end