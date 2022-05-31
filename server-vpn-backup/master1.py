# /home/ubuntu/bin/master.py

import ovh

client = ovh.Client(config_file='/home/ubuntu/bin/ovh.conf')

ip = '15.235.60.92'
ip_name = 'ip-15.235.60.92'
service = client.get("/ip/service/%s" % ip_name)
vps = (service.get("routedTo")).get("serviceName")
if vps != "vps-a1922212.vps.ovh.ca":
    print('Changing floating ip route')
    client.post("/ip/%s/move" % ip, to="vps-a1922212.vps.ovh.ca")
