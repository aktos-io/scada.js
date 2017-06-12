require! 'dcs': {Actor}

export class Monitor extends Actor
    (name='') ->
        super "Monitor #{name}"
        #@subscribe "IoMessage.my-test-pin3"

        @on-receive (msg) ~>
            @log.log "payload: ", msg.payload, "topic: ", msg.topic

    action: ->
        @log.log "#{@name} started..."
