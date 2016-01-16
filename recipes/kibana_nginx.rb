server_type = node.name.split('-')[0]
slug = node.name.split('-')[1] 
datacenter = node.name.split('-')[2]
environment = node.name.split('-')[3]
location = node.name.split('-')[4]
cluster_slug = File.read("/var/cluster_slug.txt")
cluster_slug = cluster_slug.gsub(/\n/, "") 

data_bag("meta_data_bag")
aws = data_bag_item("meta_data_bag", "aws")
domain = aws[node.chef_environment]["route53"]["domain"]

elasticsearch_server = data_bag_item("server_data_bag", "elasticsearch")
if elasticsearch_server[datacenter][environment][location].has_key?(cluster_slug)
  cluster_slug_elasticsearch = cluster_slug
else
  cluster_slug_elasticsearch = "nocluster"
end

if cluster_slug_elasticsearch=="nocluster"
  subdomain = "elasticsearch-#{slug}-#{datacenter}-#{environment}-#{location}"
else
  subdomain = "elasticsearch-#{slug}-#{datacenter}-#{environment}-#{location}-#{cluster_slug_elasticsearch}"
end
required_count = elasticsearch_server[datacenter][environment][location][cluster_slug_elasticsearch]['required_count']
full_domain = "#{subdomain}.#{domain}"

elasticsearch_host = "1-#{full_domain}"

template "/etc/nginx/sites-available/kibana.nginx.conf" do
  path "/etc/nginx/sites-available/kibana.nginx.conf"
  source "kibana.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
  variables :elasticsearch_host => elasticsearch_host
end

link "/etc/nginx/sites-enabled/kibana.nginx.conf" do
  to "/etc/nginx/sites-available/kibana.nginx.conf"
end
service "nginx"