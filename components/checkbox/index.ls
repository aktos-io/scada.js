require! 'aea': {sleep, VLogger}

"""
usage:
    attributes:
        tristate="true": display a "CLEAR" button

checked="{{value}}" : where the value is one of true/false/null
"""

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
                @set \check-state, 'indetermined'
                @set \checked, null
            else
                if state is \false
                    state = false
                @set \checked, state
                @set \check-state, if state then \checked else \unchecked
                ack-button.fire \state, \done

        if @get \topic
            ack-button.actor.subscribe that
            ack-button.actor.on \data, (msg) ~>
                if that is msg.topic
                    set-state msg.payload.curr

            ack-button.actor.request-update that

        @observe \checked, set-state

        if typeof! @get(\checked) is \Undefined
            set-state @get \initial

        @on do
            _statechange: (ctx) ->
                if (@has-event 'statechange') or @get \async
                    ctx.component.fire \state, \doing
                    ctx.component.heartbeat 9999999999ms

                    @set \check-state, \doing
                    checked = @get \checked

                    #logger.clog "sending handler the next check state: from", checked, "to", (not checked)
                    checked = not checked

                    const c = ctx.getParent yes
                    c.refire = yes
                    c.actor = ack-button.actor
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
                    curr-state = @get \checked
                    unless @get \tristate
                        set-state not curr-state
                    else
                        if curr-state is true
                            # change the state-vector direction
                            @set \state-vector, \down
                            set-state null
                        else
                            if typeof! curr-state in <[ Null Undefined ]>
                                set-state (@get \state-vector) is \up
                            else
                                @set \state-vector, \up
                                set-state null


    data: ->
        checked: undefined
        'check-state': 'unchecked'
        transparent: no
        initial: false
        'state-vector': \up  # up/down
