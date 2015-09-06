from aktos_dcs import * 

from pprint import pprint 

class Test(Actor):
    def receive(self, msg):
        print "Test got message: "
        pprint(msg)

    def action(self):
        val = False
        while True: 
            print "sending val: ", val
            self.send(IoMessage(pin_name='mesut', val=val))
            val = not val
            sleep(4)

ProxyActor()
Test()
wait_all()
