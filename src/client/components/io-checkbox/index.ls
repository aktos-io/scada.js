require! '../io-pushbutton/button-actor': {ButtonActor}

cb-states =
    checked: 1
    unchecked: 0

cb-state-names =
    0: \unchecked
    1: \checked

Ractive.components['io-checkbox'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    onrender: ->
        topic = @get \topic
        unless topic
            console.error "topic is required"
            return

        checkbox = @find-component \checkbox

        actor = new ButtonActor {topic: topic}
        actor.on \data, (msg) ~>
            if msg.payload.curr?
                that = msg.payload.curr
                #actor.log.log "Received state update: #{that}"
                checkbox.fire \state, cb-state-names[that]
                @set \curr, that

        actor.request-update topic

        @on do
            toggleOutput: (ev, curr, next) ->
                ev.component.fire \state, \doing
                #console.log "checkbox for #{topic} is toggled to be #{next}"
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
