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

    def action(self):
        i = 0
        while True:
            print "sending analog-1 value"
            self.send(IoMessage(pin_name="analog-1", val=i))
            i += 1
            sleep(1)




ProxyActor(brokers="192.168.2.116:5012:5013")
KeypadSimulator()
wait_all()
