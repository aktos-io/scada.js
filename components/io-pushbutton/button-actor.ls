require! 'dcs/browser': {Actor, Signal}

export class ButtonActor extends Actor
    (@opts) ->
        @topic = "#{@opts.topic}"
        super @topic
        @subscribe @topic
        @timeout = 4000ms

    send-io: (data) ->
        @send data, @topic

    write: (val, callback) ->
        #@log.log "sending #{value}"
        timeout, msg <~ @send-request {@topic, @timeout}, {val}
        callback (timeout or msg.payload.err), msg
