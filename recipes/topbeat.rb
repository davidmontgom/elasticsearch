


version = '1.2.1'
remote_file "#{Chef::Config[:file_cache_path]}/topbeat/topbeat_#{version}_amd64.deb" do
    source "https://download.elastic.co/beats/topbeat/topbeat_1.2.1_amd64.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/topbeat_#{version}_amd64.deb" do
  action :install
end




service "topbeat" do
  supports :restart => true, :start => true, :stop => true
  action [ :enable, :start]
end


template "/etc/topbeat/topbeat.yml.erb" do
    path "/etc/topbeat/topbeat.yml.erb"
    source "topbeat.#{version}.yml.erb"
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

