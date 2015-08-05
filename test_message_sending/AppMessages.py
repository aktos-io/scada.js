from aktos_dcs.Messages import *

class IoMessage(Message):
    edge = None
    pin_name = None 
    pin_number = None
    val = None
    last_change = None 

class UpdateIoMessage(Message):
    pass


