require! 'dcs': {Actor, Broker}
require! 'aea': {sleep}
require! 'dcs': {Broker}

class PlcSimulator extends Actor
    (opts) ->
        super opts.name

        @on-receive (msg) ->
            @log.log "got msg to write: ", msg.topic, "payload: " msg.payload

    action: -> 
        do
            tmp1 = off
            tmp2 = 0
            <~ :lo(op) ~>
                @send tmp1, "#{@name}.testInput"
                tmp1 := not tmp1
                @send tmp2++, "#{@name}.testLevel1"
                <~ sleep 1000ms
                lo(op)


new PlcSimulator do
    target: {port: 102, host: '192.168.0.1', rack: 0, slot: 1}
    name: \my-test-plc
    memory-map:
        test-input: 'I0.0'
        test-output: 'Q0.1'
        test-level1: 'MD84'

new Broker!
