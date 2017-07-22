require! 'dcs/browser': {Actor, Signal}

cb-states =
    checked: 1
    unchecked: 0

cb-state-names =
    0: \unchecked
    1: \checked

class ButtonActor extends Actor
    (@opts) ->
        @topic = "#{@opts.topic}"
        super @topic
        @subscribe @topic

        @ack = new Signal!

        @on \data, (msg) ~>
            @log.log "change value: #{msg.payload.curr} (before: #{msg.payload.prev})"
            @ack.go msg

    send-io: (data) ->
        @send data, @topic


    write: (value, callback) ->
        @log.log "sending #{value}"
        @ack.clear!
        @send-io {val: value}
        reason, msg <~ @ack.wait 4000ms
        err = reason is \timeout
        @log.log "response arrived: "
        console.log msg

        callback err, msg

Ractive.components['io-checkbox'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    onrender: ->
        topic = @get \topic
        checkbox = @find-component \checkbox
        unless topic
            console.error "topic is required"
            return

        actor = new ButtonActor {topic: topic}
        actor.on \data, (msg) ~>
            if msg.payload.curr?
                that = msg.payload.curr
                actor.log.log "Received state update: #{that}"
                checkbox.fire \state, cb-state-names[that]
                @set \curr, that

        actor.request-update topic

        @on do
            toggleOutput: (ev, curr, next) ->
                ev.component.fire \state, \doing
                console.log "checkbox for #{topic} is toggled to be #{next}"
                err, res <~ actor.write cb-states[next]
                if err
                    ev.component.fire \error, message: "error writing output: #{err}"
                else
                    try
                        @set \curr, res.payload.curr
                        if res.payload.curr is cb-states[next]
                            ev.component.fire \state, next
                        else
                            ev.component.fire \state, curr
                            ev.component.fire \error, message: "Could not change state!"
                    catch
                        debugger
