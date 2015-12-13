#
# Cookbook Name:: elk-data
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt'

%w{default-jdk}.each do |pkg|
  package pkg do
    action [:install]
  end
end
remote_file "/tmp/elasticsearch-1.7.3.deb" do
  source "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.3.deb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

execute "install elasticsearch" do
  command "dpkg -i /tmp/elasticsearch-1.7.3.deb"
end

execute 'install_bigdesk' do
  command '/usr/share/elasticsearch/bin/plugin -i lukas-vlcek/bigdesk'
end

execute 'install_head' do
  command '/usr/share/elasticsearch/bin/plugin -i mobz/elasticsearch-head'
end

execute 'install_ec2-plugin' do
  command '/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-cloud-aws/2.7.0'
end

template "/etc/elasticsearch/elasticsearch.yml" do
        source "elasticsearch-config.erb"
        mode "0644"
end

service "elasticsearch" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :restart ]
end

