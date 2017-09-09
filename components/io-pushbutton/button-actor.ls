require! 'dcs/browser': {Actor, Signal}

export class ButtonActor extends Actor
    (@opts) ->
        @topic = "#{@opts.topic}"
        super @topic
        @subscribe @topic

        @ack = new Signal!

        @on \data, (msg) ~>
            #@log.log "change value: #{msg.payload.curr} (before: #{msg.payload.prev})"
            @ack.go msg

    send-io: (data) ->
        @send data, @topic

    write: (value, callback) ->
        #@log.log "sending #{value}"
        @ack.clear!
        @send-io {val: value}
        err, msg <~ @ack.wait 4000ms
        #@log.log "response arrived: "
        #console.log msg

        callback err, msg
