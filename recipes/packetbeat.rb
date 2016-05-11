
version = '1.2.1'
remote_file "#{Chef::Config[:file_cache_path]}/packetbeat/packetbeat_#{version}_amd64.deb" do
    source "https://download.elastic.co/beats/packetbeat/packetbeat_#{version}_amd64.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/packetbeat_#{version}_amd64.deb" do
  action :install
end


service "packetbeat" do
  supports :restart => true, :start => true, :stop => true
  action [ :enable, :start]
end


template "/etc/packetbeat/packetbeat.yml.erb" do
    path "/etc/packetbeat/packetbeat.yml.erb"
    source "packetbeat.#{version}.yml.erb"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, resources(:service => "topbeat")
end


=begin
service "supervisord" 
template "/etc/supervisor/conf.d/supervisord.filebeat.conf" do
      path "/etc/supervisor/conf.d/supervisord.filebeat.conf"
      source "supervisord.filebeat.conf.erb"
      owner "root"
      group "root"
      mode "0755"
      variables({
        :version => version
      })
      notifies :restart, resources(:service => "supervisord")
end
=end

