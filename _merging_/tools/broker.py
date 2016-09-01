from aktos_dcs import *

class Monitor(Actor):
    def handle_IoMessage(self, msg):
        print "monitor got io message:", msg['pin_name'], msg['val']

ProxyActor(proxy_brokers="localhost:9012:9013", brokers="10.0.10.176:5012:5013")
Monitor()
wait_all()
