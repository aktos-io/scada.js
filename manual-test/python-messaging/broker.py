from aktos_dcs import *
from aktos_dcs_lib import *

class Monitor(Actor):
    def handle_IoMessage(self, msg):
        msg = get_msg_body(msg)
        print "monitor got io message:", msg['pin_name'], msg['val']

ProxyActor(proxy_brokers="localhost:9012:9013")
Monitor()
wait_all()
