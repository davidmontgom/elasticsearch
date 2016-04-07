




version = '2.3.1-1'
remote_file "#{Chef::Config[:file_cache_path]}/logstash_#{version}_all.deb" do
    source "https://download.elastic.co/logstash/logstash/packages/debian/logstash_#{version}_all.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/logstash_#{version}_all.deb" do
  action :install
end
 
 
=begin
service "supervisord"

template "/var/logstash.conf " do
    path "/var/logstash.conf"
    source "logstash.#{version}.conf.erb"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, resources(:service => "supervisord")
end
  
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

