from aktos_dcs import * 
from aktos_dcs_lib import *

for i in range(20):
    pin_name = "vpin-%d" % i
    VirtualIoActor(pin_name=pin_name)

ProxyActor()
print "Started virtual io-server..."
wait_all()
