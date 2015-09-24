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