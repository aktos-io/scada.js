require! 'aktos-dcs/src/actor': {Actor}
require! 'aea': {sleep}

export class Monitor extends Actor
    (name='') ->
        super "Monitor #{name}"
        #@subscribe "IoMessage.my-test-pin3"

        @on-receive (msg) ~>
            @log.log "payload: ", msg.payload, "topic: ", msg.topic

    action: ->
        @log.log "#{@name} started..."

export class Simulator extends Actor
    ->
        super 'simulator'

        @on-receive (msg) ~>
            @log.log "Simulator got message: ", msg.payload
            #@echo msg

    action: ->
        @log.log "Simulator started..."

    echo: (msg) ->
        @log.log "Got message: Payload: ", msg.payload
        msg.payload++
        @log.log "...payload incremented by 1: ", msg.payload
        @log.log "Echoing message back in 1000ms..."
        <~ sleep 1000ms
        @send_raw msg
