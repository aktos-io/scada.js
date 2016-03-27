from aktos_dcs import * 

for i in range(2000):
    pin_name = "vpin-%d" % i
    VirtualIoActor(pin_name=pin_name)

ProxyActor()
print "Started virtual io-server..."
wait_all()
