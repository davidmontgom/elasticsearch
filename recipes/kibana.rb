server_type = node.name.split('-')[0]
slug = node.name.split('-')[1] 
datacenter = node.name.split('-')[2]
environment = node.name.split('-')[3]
location = node.name.split('-')[4]
cluster_slug = File.read('/var/cluster_slug.txt')
cluster_slug = cluster_slug.gsub(/\n/, "") 


elasticsearch_server = data_bag_item("server_data_bag", "elasticsearch")
if elasticsearch_server['haproxy'].has_key?("elasticsearch-#{cluster_slug}")
  es_proxy_port = elasticsearch_server['haproxy']["elasticsearch-hugo"]["proxy_port"]
else
  es_proxy_port = 9200
end

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

dpkg_package "#{Chef::Config[:file_cache_path]}/kibana-#{kibana_version}-amd64.deb" do
  action :install
end

service "kibana" do
  supports :restart => true, :start => true, :stop => true
  action [ :enable, :start]
end


template "/etc/kibana/kibana.yml" do
    path "/etc/kibana/kibana.yml"
    source "kibana.#{kibana_version}.yml.erb"
    owner "root"
    group "root"
    mode "0755"
    variables lazy {{:es_proxy_port => "#{es_proxy_port}"}}
    notifies :restart, resources(:service => "kibana")
end

=begin
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






