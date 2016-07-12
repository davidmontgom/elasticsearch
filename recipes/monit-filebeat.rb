service "monit"
template "/etc/monit/conf.d/filebeat.conf" do
  path "/etc/monit/conf.d/filebeat.conf"
  source "monit.filebeat.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, resources(:service => "monit")
end