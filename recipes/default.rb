server_type = node.name.split('-')[0]
slug = node.name.split('-')[1] 
datacenter = node.name.split('-')[2]
environment = node.name.split('-')[3]
location = node.name.split('-')[4]
cluster_slug = File.read("/var/cluster_slug.txt")
cluster_slug = cluster_slug.gsub(/\n/, "") 


data_directory = "/data"


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


ram = node['memory']['total'].to_i / 1000
heap_size = (ram*0.5)

if ram==1
  heap_size='512m'
end
if ram>1
  heap_size = (ram*0.5).round/1000
  heap_size = "#{heap_size}g"
end

#https://discuss.elastic.co/t/how-to-check-es-heap-size/36613/5
#curl -sS -XGET "localhost:9200/_cat/nodes?h=heap*&v"
#sed -i -e '2iES_HEAP_SIZE=4g\' /etc/init.d/elasticsearch



bash 'ES_HEAP_SIZE' do
  code <<-EOH 
    
    touch /var/chef/cache/heap.lock
    touch /tmp/wow_#{heap_size}
    export ES_HEAP_SIZE=#{heap_size}
    echo 'export ES_HEAP_SIZE=#{heap_size}' | tee -a /root/.bashrc
    echo 'elasticsearch soft memlock unlimited' | tee -a /etc/security/limits.conf
    echo 'elasticsearch hard memlock unlimited' | tee -a /etc/security/limits.conf
    sysctl -w vm.max_map_count=262144
    sysctl -w vm.swappiness=1
    sysctl -w fs.file-max=100000
    ulimit -l unlimited
    source /root/.bashrc
  EOH
  environment 'ES_HEAP_SIZE' => '#{heap_size}'
  action :run
  not_if {File.exists?("/var/chef/cache/heap.lock")}
end

=begin
 curl http://localhost:9200/_nodes/process?pretty
 curl localhost:9200/_nodes/stats/process?pretty
 curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'
 cat /proc/sys/fs/file-max
=end







if cluster_slug=="nocluster"
  clustername = "elasticsearch#{slug}#{datacenter}#{location}#{node.chef_environment}"
else
  clustername = "elasticsearch#{slug}#{datacenter}#{location}#{node.chef_environment}#{cluster_slug}"
end


version = node[:elasticsearch][:version]
remote_file "#{Chef::Config[:file_cache_path]}/elasticsearch-#{version}.deb" do
    source "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/#{version}/elasticsearch-#{version}.deb"
    action :create_if_missing
end

dpkg_package "#{Chef::Config[:file_cache_path]}/elasticsearch-#{version}.deb" do
  action :install
end


bash 'ES_HEAP_SIZE_init' do
  code <<-EOH 
    ulimit -l unlimited
    sed -i -e '2iES_HEAP_SIZE=#{heap_size}\' /etc/init.d/elasticsearch
    touch /var/chef/cache/heap_init.lock
  EOH
  action :run
  not_if {File.exists?("/var/chef/cache/heap_init.lock")}
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

directory "#{data_directory}" do
  #mode "0777"
  owner 'elasticsearch'
  group 'elasticsearch'
  action :create
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



 










