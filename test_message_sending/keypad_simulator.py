from aktos_dcs import *


class KeypadSimulator(Actor):
    def handle_IoMessage(self, msg):
        msg = msg_body(msg)
        print "keypad simulator got io message:", msg['pin_name'], msg['val']
        try:
            source, number = msg.pin_name.split('-')
            assert source == 'button'
            print "sending button press: ", number, msg['val']
            self.send({'KeypadMessage': {'key': number, 'val': msg['val']}})
        except:
            pass

        if msg['pin_name'] == "test-slider":
            print "slider value changed to: ", msg['val']

    def action(self):
        i = 0
        while True:
            print "sending analog-1 value"
            self.send({'IoMessage':{'pin_name':'analog-1', 'val':i}})
            self.send({'IoMessage':{'pin_name':'analog-2', 'val':i*10}})
            i += 1
            sleep(1)



ProxyActor()
KeypadSimulator()
wait_all()
