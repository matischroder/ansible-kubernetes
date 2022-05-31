# /home/ubuntu/bin/master.py

import ovh

client = ovh.Client(config_file='/home/ubuntu/bin/ovh.conf')

ip = '15.235.60.92'
ip_name = 'ip-15.235.60.92'
print('Changing floating ip route')
service = client.get("/ip/service/%s" % ip_name)
vps = (service.get("routedTo")).get("serviceName")
if vps != "vps-e7d30833.vps.ovh.ca":
    print('Changing floating ip route')
    client.post("/ip/%s/move" % ip, to="vps-e7d30833.vps.ovh.ca")
