from aktos_dcs.Messages import *

class IoMessage(Message):
    edge = None
    pin_name = ""
    pin_number = ""
    val = None
    last_change = None

class UpdateIoMessage(Message):
    pass

class KeypadMessage(Message):
    key = ""
    edge = "none"
    val = ""

class MotorMessage(Message):
    pass


class CabinHeightMessage(Message):
    pass


class LimitMessage(Message):
    pass
