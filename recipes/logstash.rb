
=begin
 
 If want to use redis add the below and besure to add redis to haproxy
 
 redis { 
    host => "localhost" 
    type => "redis-input" 
    data_type => "list" 
    key => "logstash" 
  } 
 
  
=end


version = node[:elasticsearch][:logstash][:version]
remote_file "#{Chef::Config[:file_cache_path]}/logstash_#{version}_all.deb" do
    source "https://download.elastic.co/logstash/logstash/packages/debian/logstash_#{version}_all.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/logstash_#{version}_all.deb" do
  action :install
end
 
 
service "logstash" do
  supports :start => true, :stop => true, :restart => true
  action [ :enable, :start]
end


template "/etc/logstash/conf.d/logstash.conf" do
    path "/etc/logstash/conf.d/logstash.conf"
    source "logstash.#{version}.conf.erb"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, resources(:service => "logstash")
end
  
=begin
 service "supervisord" 

template "/etc/supervisor/conf.d/supervisord.logstash.conf" do
      path "/etc/supervisor/conf.d/supervisord.logstash.conf"
      source "supervisord.logstash.conf.erb"
      owner "root"
      group "root"
      mode "0755"
      variables({
        :version => version
      })
      notifies :restart, resources(:service => "supervisord")
end
=end

logrotate_app "logstash-rotate" do
  cookbook "logrotate"
  path ["/var/log/logstash/logstash.log"]
  frequency "daily"
  rotate 1
  size "1M"
  create "644 root root"
end

=begin
 
 
/opt/logstash/bin/logstash --configtest -f /etc/logstash/conf.d/ 

curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.2.3.zip

=end

























