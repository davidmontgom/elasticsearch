service "monit"
template "/etc/monit/conf.d/elasticsearch.conf" do
  path "/etc/monit/conf.d/elasticsearch.conf"
  source "monit.elasticsearch.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit")
end