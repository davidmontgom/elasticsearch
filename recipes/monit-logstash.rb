service "monit"
template "/etc/monit/conf.d/logstash.conf" do
  path "/etc/monit/conf.d/logstash.conf"
  source "monit.logstash.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit")
end