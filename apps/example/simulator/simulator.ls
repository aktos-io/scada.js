"""
This simulator receives a message, doubles the payload and re-sends to the
DCS network.
"""

require! 'aktos-dcs/src/actor': {Actor}
require! 'aktos-dcs/src/broker': {Broker}
require! 'aea': {sleep}

export class IncrementingEcho extends Actor
    (topic) ->
        super 'simulator'
        @subscribe topic 

        @on-receive (msg) ~>
            @echo msg

    action: ->
        @log.log "Simulator started..."

    echo: (msg) ->
        @log.log "Payload: ", msg.payload, "topic: ", msg.topic
        msg.payload++
        @log.log "...payload incremented by 1: ", msg.payload
        @log.log "Echoing message back in 1000ms..."
        <~ sleep 1000ms
        @send_raw msg

new Broker!
new IncrementingEcho 'IoMessage.my-test-pin3'
