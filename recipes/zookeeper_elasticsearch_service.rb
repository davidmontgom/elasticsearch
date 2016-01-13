datacenter = node.name.split('-')[0]
environment = node.name.split('-')[1]
location = node.name.split('-')[2]
server_type = node.name.split('-')[3]
slug = node.name.split('-')[4] 
cluster_slug = File.read("/var/cluster_slug.txt")
cluster_slug = cluster_slug.gsub(/\n/, "") 

  
data_bag("my_data_bag")
zk = data_bag_item("my_data_bag", "zk")
zk_hosts = zk[node.chef_environment][datacenter][location]["zookeeper_hosts"]



db = data_bag_item("my_data_bag", "my")
keypair=db[node.chef_environment][location]["ssh"]["keypair"]
username=db[node.chef_environment][location]["ssh"]["username"]

easy_install_package "zc.zk" do
  action :install
end

easy_install_package "paramiko" do
  action :install
end


if datacenter!='local'
script "zookeeper_add_elasticsearch" do
    interpreter "python"
    user "root"
code <<-PYCODE
import os
import zc.zk
import logging 
import json
logging.basicConfig()
import paramiko
username='#{username}'
zookeeper_hosts = '#{zk_hosts}'
zk_host_list = '#{zk_hosts}'.split(',')
for i in xrange(len(zk_host_list)):
    zk_host_list[i]=zk_host_list[i]+':2181' 
zk_host_str = ','.join(zk_host_list)
zk = zc.zk.ZooKeeper(zk_host_str)

ip_address_list = zookeeper_hosts.split(',')    
node = '#{datacenter}-elasticsearch-#{location}-#{node.chef_environment}'
path = '/%s/' % (node)

if zk.exists(path):
    addresses = zk.children(path)
    elasticsearch_ip_list = list(set(addresses))
    unicast_hosts = elasticsearch_ip_list
    unicast_hosts.append('#{node[:ipaddress]}')
    unicast_hosts = list(set(unicast_hosts))
    unicast_hosts = json.dumps(unicast_hosts)
    f = open('#{Chef::Config[:file_cache_path]}/unicast_hosts','w')
    f.write(unicast_hosts)
    f.close()
    for ip_address in elasticsearch_ip_list:
        if ip_address!="#{node[:ipaddress]}":
            keypair_path = '/root/.ssh/#{keypair}'
            key = paramiko.RSAKey.from_private_key_file(keypair_path)
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(ip_address, 22, username=username, pkey=key)
            cmd = "sudo ufw allow from #{node[:ipaddress]}"
            stdin, stdout, stderr = ssh.exec_command(cmd)
            out = stdout.read()
            err = stderr.read()
            cmd = "rm #{Chef::Config[:file_cache_path]}/unicast_hosts"
            stdin, stdout, stderr = ssh.exec_command(cmd)
            cmd = """echo '%s' | tee -a '#{Chef::Config[:file_cache_path]}/unicast_hosts'""" % unicast_hosts
            stdin, stdout, stderr = ssh.exec_command(cmd)
            out = stdout.read()
            err = stderr.read()
            print "out--", out
            ssh.close()
            os.system("sudo ufw allow from %s" % ip_address)
            os.system("sudo ufw allow from %s" % ip_address)  
        
PYCODE
end
end