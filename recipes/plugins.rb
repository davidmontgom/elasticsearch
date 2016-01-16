
=begin
bash "elasticsearch-head" do
  user "root"
  cwd "/usr/share"
  code <<-EOH
    sudo elasticsearch/bin/plugin -install mobz/elasticsearch-head
    sudo elasticsearch/bin/plugin -install elasticsearch/marvel/latest
    sudo elasticsearch/bin/plugin --install jettro/elasticsearch-gui 
    touch /var/chef/cache/elasticsearch-head.lock
  EOH
  action :run
  not_if {File.exists?("/var/chef/cache/elasticsearch-head.lock")}
end
=end

#http://1-elasticsearch-do-development-ny-forex.forexhui.com:5601/app/kibana
#http://1-elasticsearch-do-development-ny-forex.forexhui.com:5601/app/marvel


bash "marvel_install" do
  user "root"
  cwd "/usr/share"
  code <<-EOH
    cd /usr/share/elasticsearch
    sudo bin/plugin install license
    sudo bin/plugin install marvel-agent
    touch /var/chef/cache/elasticsearch-head.lock
  EOH
  action :run
  not_if {File.exists?("/var/chef/cache/elasticsearch-head.lock")}
end

kibana_version = "4.3.1"
bash "kibana_kibana" do
  user "root"
  cwd "/usr/share"
  code <<-EOH
    cd /var
    wget https://download.elastic.co/kibana/kibana/kibana-#{kibana_version}-linux-x64.tar.gz
    tar -xvf kibana-#{kibana_version}-linux-x64.tar.gz
    cd kibana-#{kibana_version}-linux-x64
    bin/kibana plugin --install elasticsearch/marvel/latest
    touch /var/chef/cache/kibana.lock
  EOH
  action :run
  not_if {File.exists?("/var/chef/cache/kibana.lock")}
end



template "/var/kibana-#{kibana_version}-linux-x64/config/kibana.yml" do
    path "/var/kibana-#{kibana_version}-linux-x64/config/kibana.yml"
    source "kibana.#{kibana_version}.yml.erb"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, resources(:service => "elasticsearch")
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








