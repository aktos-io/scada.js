from aktos_dcs import *
from aktos_dcs_lib import * 

class Monitor(Actor):
    def handle_IoMessage(self, msg):
        msg = msg_body(msg)
        print "monitor got io message:", msg['pin_name'], msg['val']

ProxyActor()
Monitor()
wait_all()
