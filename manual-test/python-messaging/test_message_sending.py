from aktos_dcs import * 

from pprint import pprint 

class Test(Actor):
    def receive(self, msg):
        print "Test got message: "
        pprint(msg)

    def action(self):
        value = 0
        while True:
            self.send({'IoMessage': {'pin_name': 'gauge-slider', 'val': value}})
            value += 1
            sleep(1)

ProxyActor()
Test()
wait_all()
