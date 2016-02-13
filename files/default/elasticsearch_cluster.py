import argparse
import os
import zc.zk
import logging 
import json
logging.basicConfig()
import paramiko
import dns.resolver
import subprocess
from zoo import *
from pprint import pprint

    
def elasticearch(args):
    
    zoo = zookeeper(args)
    zk = zoo.get_conn()
    path = zoo.get_path()
    
    ip_address = args.ip_address
    username = args.username
    keypair = args.keypair
     
    unicast_hosts = [ip_address]
    if zk.exists(path):
        addresses = zk.children(path)
        ip_address_list = list(set(addresses))
        unicast_hosts = unicast_hosts + ip_address_list
        unicast_hosts = list(set(unicast_hosts))
    
        cmd_list = ["""echo '%s' | tee -a '/var/chef/cache/unicast_hosts'""" % unicast_hosts]
        iptables_remote(ip_address,ip_address_list,keypair,username,cmd_list=cmd_list,datacenter=arg.datacenter)
        iptables_local(ip_address,ip_address_list,datacenter=arg.datacenter)
    else: 
        unicast_hosts = json.dumps(unicast_hosts)        
    f = open('/var/chef/cache/unicast_hosts','w')
    f.write(unicast_hosts)
    f.close()
    if zk:
        zoo.close()





if __name__ == "__main__":
    
    """
    python test.py --server_type elasticsearch --username root --ip_address 192.34.59.12 --zk_count 1 \
           --zk_hostname zookeeper-forex-do-development-ny.forexhui.com \
           --datacenter do --environment development --location ny --slug forex --keypair  id_rsa_forex_do
    
    
    """
    
    parser = argparse.ArgumentParser(description='Node')
    
    
    parser.add_argument('--server_type', action="store", default=None, help="server_type")
    parser.add_argument('--username', action="store", default=None, help="username")
    parser.add_argument('--ip_address', action="store", default=None, help="ipaddress")
    parser.add_argument('--zk_count', action="store", default=None, help="zk_count")
    parser.add_argument('--zk_hostname', action="store", default=None, help="zk_hostname")
    parser.add_argument('--datacenter', action="store", default=None, help="datacenter")
    parser.add_argument('--environment', action="store", default=None, help="environment")
    parser.add_argument('--location', action="store", default=None, help="location")
    parser.add_argument('--slug', action="store", default=None, help="slug")
    parser.add_argument('--cluster_slug', action="store", default='nocluster', help="cluster_slug")
    parser.add_argument('--shard', action="store", default=None, help="shard")
    parser.add_argument('--keypair', action="store", default=None, help="keypair")
    
    args = parser.parse_args()
    fn = os.path.realpath(__file__)
    
    f = open('/tmp/%s_zk.sh' % fn.split('/')[-1].replace('.py',''),'w')
    temp = '/usr/bin/python %s ' % fn
    f.write(temp)
    for arg in vars(args):
        line =  '--%s %s ' % (arg, getattr(args, arg))
        f.write(line)
    f.close()

    elasticearch(args)













