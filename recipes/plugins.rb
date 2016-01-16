
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

#http://1-elasticsearch-do-development-ny-forex.forexhui.com:9200/_plugin/marvel/

bash "elasticsearch-head" do
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