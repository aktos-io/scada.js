from aktos_dcs import *

class KeypadSimulator(Actor):
    def handle_IoMessage(self, msg):
        print "keypad simulator got io message:", msg.pin_name, msg.val
        try:
            source, number = msg.pin_name.split('-')
            assert source == 'button'
            print "sending button press: ", number, msg.val
            self.send(KeypadMessage(key=number, val=msg.val))
        except:
            pass




ProxyActor(brokers="192.168.2.116:5012:5013")
KeypadSimulator()
wait_all()
