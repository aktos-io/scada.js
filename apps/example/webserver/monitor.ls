require! 'dcs': {Actor}

export class Monitor extends Actor
    (name='') ->
        super "Monitor #{name}"
        @subscribe '**'
        @log.log "subscribed: #{@subscriptions}"

        @on-receive (msg) ~>
            if \update of msg
                @log.log "***update message: ", msg.update, "\t\ttopic: ", msg.topic
            if \payload of msg
                @log.log "data message: ", msg.payload, "\t\ttopic: ", msg.topic

    action: ->
        @log.log "#{@name} started..."
