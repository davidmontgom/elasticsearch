data_bag("my_data_bag")
db = data_bag_item("my_data_bag", "my")

datacenter = node.name.split('-')[0]
server_type = node.name.split('-')[1]
location = node.name.split('-')[2]


if location!='local'
  bash "swap" do
    user "root"
    code <<-EOH
      swapoff -a
      touch /var/chef/cache/swap.lock
    EOH
    action :run
    not_if {File.exists?("/var/chef/cache/swap.lock")}
  end
end

clustername = 'feed#{node.chef_environment}cluster'
version = node[:elasticsearch][:version]
  
remote_file "#{Chef::Config[:file_cache_path]}/elasticsearch-#{version}.deb" do
  source "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{version}.deb"
  action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/elasticsearch-#{version}.deb" do
  action :install
end

service "elasticsearch" do
  supports :restart => true, :start => true, :stop => true
  action [ :enable, :start]
end

package "unzip" do
  action :install
end
package "git" do
  action :install
end

package "iotop" do
  action :install
end
package "dstat" do
  action :install
end
package "htop" do
  action :install
end

directory "/etc/elasticsearch/templates" do
  mode "0777"
  owner 'elasticsearch'
  group 'elasticsearch'
  action :create
end


if location!='local'
  if File.exists?("#{Chef::Config[:file_cache_path]}/unicast_hosts")
    unicast_hosts = File.read("#{Chef::Config[:file_cache_path]}/unicast_hosts")
  else
    unicast_hosts = "['#{node[:ipaddress]}']"
  end

  template "/etc/elasticsearch/elasticsearch.yml" do
    path "/etc/elasticsearch/elasticsearch.yml"
    source "elasticsearch.#{version}.yml.erb"
    owner "root"
    group "root"
    mode "0755"
    variables lazy {{:clustername => "#{clustername}",
                     :unicast_hosts => File.read("#{Chef::Config[:file_cache_path]}/unicast_hosts")}}
    notifies :restart, resources(:service => "elasticsearch")
  end
  
end