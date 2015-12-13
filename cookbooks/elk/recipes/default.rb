#
# Cookbook Name:: elk
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
  action [ :enable, :start ]
end

template "/etc/ssl/openssl.cnf" do
  source "openssl.erb"
  owner "root"
  group "root"
  mode "0644"
end

directory "/etc/logstash/conf.d/" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

directory "/etc/pki/tls/certs/" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

directory "/etc/pki/tls/private" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end


execute 'install_certificate' do
  command 'cd /etc/pki/tls && sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt'
end

template "/etc/logstash/conf.d/01-lumberjack-input.conf" do
  source "01-lumberjack-input.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/logstash/conf.d/10-syslog.conf" do
  source "10-syslog.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/logstash/conf.d/11-logstash-logger.conf" do
  source "11-logstash-logger.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/logstash/conf.d/12-logstash-logger.conf" do
  source "12-logstash-logger.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/logstash/conf.d/30-lumberjack-output.conf" do
  source "30-lumberjack-output.erb"
  owner "root"
  group "root"
  mode "0644"
end

remote_file "/tmp/logstash_1.5.5-1_all.deb" do
  source "https://download.elastic.co/logstash/logstash/packages/debian/logstash_1.5.5-1_all.deb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

execute "install logstash" do
  command "dpkg -i /tmp/logstash_1.5.5-1_all.deb"
end

service "logstash" do
  supports :status => true, :restart => true, :truereload => true
  action [ :start ]
end
remote_file "/tmp/kibana-4.1.2-linux-x64.tar.gz" do
  source "https://download.elastic.co/kibana/kibana/kibana-4.1.2-linux-x64.tar.gz"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

directory "/opt/kibana" do
  owner "root"
  group "root"
  mode "0644"
  action :create
end

execute "extract kibana" do
  command "tar -xvf /tmp/kibana-4.1.2-linux-x64.tar.gz -C /opt/kibana --strip-components=1"
end

remote_file "/etc/init.d/kibana4" do
  source "https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/bce61d85643c2dcdfbc2728c55a41dab444dca20/kibana4"
  owner "root"
  group "root"
  mode "0755"
end

execute "start_kibana" do
  command "/etc/init.d/kibana4 start"
end
execute "install nginx" do
  command "sudo apt-get install nginx apache2-utils -y"
end
template "/etc/nginx/sites-available/default" do
  source "nginx-default.erb"
  owner "root"
  group "root"
  mode "0644"
end
template "/etc/nginx/htpasswd.users" do
  source "htpasswd.erb"
  owner "root"
  group "root"
  mode "0644"
end
service "nginx" do
  supports :status => true, :restart => true, :truereload => true
  action [ :restart ]
end
execute "restart" do
  command "/etc/init.d/logstash restart"
end
execute "restart" do
  command "/etc/init.d/kibana4 restart"
end

template "/root/dailybackup-snapshot.sh" do
  source "dailybackup-snapshot.erb"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/crontab" do
  source "crontab.erb"
  owner "root"
  group "root"
  mode "0755"
end

