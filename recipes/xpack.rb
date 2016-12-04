server_type = node.name.split('-')[0]


if server_type == 'elasticsearch'
    bash 'elasticsearch_xpack' do
        code <<-EOH
        cd /usr/share/elasticsearch
        echo 'y' |  bin/elasticsearch-plugin install x-pack
        EOH
    action :run
    end
end

if server_type = 'kibana'
    bash 'kibana_xpack' do
        code <<-EOH
        cd /usr/share/kibana/
        echo 'y' | bin/kibana-plugin install x-pack
        EOH
    action :run
    end
end








