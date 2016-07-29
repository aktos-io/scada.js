require! 'aea': {sleep}
require! 'FlashEEPROM'

export !function Config file-no
    self = this
    @file-no = file-no
    #Config.f = new (require "FlashEEPROM")(0x076000)
    Config.f = new FlashEEPROM!
    Config.f.endAddr = Config.f.addr + 1024

Config::flush = !->
    console.log "flushing to eeprom..."
    @write @ram

Config::periodic-sync = !->
    self = this
    <- :lo(op) ->
        <- sleep 3600*1000ms
        self.flush!
        lo(op)

Config::write = (data) !->
    if @write-count++ > 10
        Config.f.cleanup!
        @write-count = 0
    Config.f.write @file-no, pack data
    @ram = data

Config::read = ->
    try
        data = E.to-string Config.f.read @file-no
        @ram = unpack data
        @ram
    catch
        console.log "ERROR CONFIG READ(#{@file-no}): #{e}, raw: #{data}"
