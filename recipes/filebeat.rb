

version = '1.2.1'
remote_file "#{Chef::Config[:file_cache_path]}/filebeat_#{version}_amd64.deb" do
    source "https://download.elastic.co/beats/filebeat/filebeat_#{version}_amd64.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/filebeat_#{version}_amd64.deb" do
  action :install
end


=begin
template "/var/filebeat.yml.erb" do
    path "/var/filebeat.yml.erb"
    source "filebeat.yml.erb"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, resources(:service => "supervisord")
end
=end

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

