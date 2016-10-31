
package 'apt-transport-https' do
  action :install
end

bash "kibana_kibana" do
  user "root"
  cwd "/usr/share"
  code <<-EOH
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
  EOH
  action :run
  not_if {File.exists?("/etc/apt/sources.list.d/elastic-5.x.list")} 
end


kibana_version = node[:elasticsearch][:kibana][:version]
remote_file "#{Chef::Config[:file_cache_path]}/kibana-#{kibana_version}-amd64.deb" do  
    source "https://artifacts.elastic.co/downloads/kibana/kibana-#{kibana_version}-amd64.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/elasticsearch-#{version}.deb" do
  action :install
end

service "kibana" do
  supports :restart => true, :start => true, :stop => true
  action [ :enable, :start]
end

=begin
template "/var/kibana-#{kibana_version}-linux-x86_64/config/kibana.yml" do
    path "/var/kibana-#{kibana_version}-linux-x86_64/config/kibana.yml"
    source "kibana.#{kibana_version}.yml.erb"
    owner "root"
    group "root"
    mode "0755"
    #notifies :restart, resources(:service => "elasticsearch")
end

service "supervisord"
template "/etc/supervisor/conf.d/supervisord.kibana.conf" do
      path "/etc/supervisor/conf.d/supervisord.kibana.conf"
      source "supervisord.kibana.conf.erb"
      owner "root"
      group "root"
      mode "0755"
      variables({
        :kibana_version => kibana_version
      })
      notifies :restart, resources(:service => "supervisord")
end

=end






