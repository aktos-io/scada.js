require! 'aea': {sleep, VLogger}

Ractive.components['checkbox'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        if @get \class
            if that.index-of(\transparent)  > -1
                @set \transparent, yes

        @debug = @get \debug

    onrender: ->
        logger = new VLogger this, \checkbox

        ack-button = @find-component \ack-button

        set-state = (state) ~>
            if typeof! state in <[ Undefined Null ]>
                @set \checkState, 'undefined'
            else
                @set \checked, state
                @set \checkState, if state
                    \checked
                else
                    \unchecked
                ack-button.fire \state, \done

        if @get \topic
            ack-button.actor.subscribe that
            ack-button.actor.on \data, (msg) ~>
                if that is msg.topic
                    set-state msg.payload.curr

            ack-button.actor.request-update that

        @observe \checked, (checked) ~>
            set-state checked

        @on do
            _statechange: (ctx) ->
                if @has-event 'statechange'
                    ctx.component.fire \state, \doing
                    ctx.component.heartbeat 9999999999ms

                    @set \checkState, \doing
                    checked = @get \checked

                    #logger.clog "sending handler the next check state: from", checked, "to", (not checked)
                    checked = not checked

                    const c = ctx.getParent yes
                    c.refire = yes
                    c.actor = ack-button.actor
                    c.logger = ->
                        console.warn "This is deprecated, use actor.send 'app.log.err' instead"

                    err, callback <~ @fire \statechange, c, checked

                    if arguments.length isnt 1
                        logger.cerr "statechange callback should have exactly
                            1 argument, #{arguments.length} is given."
                        return

                    if err
                        logger.error err, callback
                    else
                        #logger.clog "no error returned, setting checkbox to ", checked
                        set-state checked
                else
                    debugger if @debug
                    set-state if @get \checked => 0 else 1

    data: ->
        checked: undefined
        checkState: 'undefined'
        transparent: no
