require! 'dcs': {Actor}

export class Monitor extends Actor
    (name='') ->
        super "Monitor #{name}"
        @subscribe '**'
        @log.log "subscribed: #{@subscriptions}"

        @on-receive (msg) ~>
            @log.log "payload: ", msg.payload, "topic: ", msg.topic

    action: ->
        @log.log "#{@name} started..."
