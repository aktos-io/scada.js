'''

# Usage:
---------

attributes:
    tristate="true": display a "CLEAR" button, allow "checked" to be undefined/null
    sync-topic="mytopic" sync with "mytopic" in realtime

checked="{{value}}" : where the value is one of
    * true
    * false
    * null or undefined (for high impedance)

'''

require! 'aea': {sleep, VLogger}
require! 'dcs/browser'
require! 'actors': {RactiveActor}


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

        set-visual = (state) ~>
            # update initial state visually
            if @get('tristate') and typeof! state in <[ Null Undefined ]>
                @set \check-state, 'indetermined'
            else
                @set \check-state, if state then \checked else \unchecked

        set-state = (state) ~>
            @set \checked, state
            set-visual state
            ack-button.fire \state, \done

        if @get \topic
            ack-button.actor.subscribe that
            ack-button.actor.on \data, (msg) ~>
                if that is msg.topic
                    set-state msg.payload.curr
            ack-button.actor.request-update that

        # set the default value on init
        unless @get \tristate
            # IMPORTANT: initial value CANNOT be applied to tristate elements.
            # ----------------------------------------------------------------
            # because "undefined" value is considered as "indeterminate", thus
            # specifying an initial value WILL cause an instable behaviour
            # because when user WANTS to set the state as "indeterminate" explicitly,
            # checkbox WOULD automatically CHANGE it to the initial value on next
            # render.
            if typeof! @get(\checked) in <[ Null Undefined ]>
                if typeof! (@get \initial) isnt \Null
                    set-state @get \initial

        unless @get \sync-topic
            # observe `checked`
            @observe \checked, ((val) ~>
                set-state val
                ), {init: false}

            # visually update on init
            set-visual @get \checked
        else
            # if it has a "sync-topic", then it should watch this topic
            topic = @get \sync-topic
            # set initial state
            @set 'check-state', \doing

            # handle realtime events
            @actor = new RactiveActor this, name=topic
                ..subscribe topic

                ..on \error, (err) ~>
                    @actor.c-err msg

                ..on-topic "#{topic}.read", (msg) ~>
                    if msg.payload.err
                        ack-button.component.warn message: that.message
                        console.error "Checkbox says: ", that
                        @set \check-state, \error
                        @set \checked, null
                    else
                        try
                            set-state msg.payload.res.curr

                ..on-topic "app.logged-in", ~>
                    @actor.c-log "DEBUG: Application is logged in into the server."

                ..request-update!

        @on do
            _statechange: (ctx) ->
                if @get \sync-topic
                    next-state = not @get \checked
                    x = sleep 100ms, ~>
                        @set 'check-state', \doing
                    topic = "#{that}.write"
                    @actor.c-log "sending: ", topic
                    timeout = 2000ms
                    _err, _res <~ @actor.send-request {topic, timeout}, next-state
                    console.log "_err, _res: ", _err, _res
                    err = _err or _res?.payload.err
                    res = (try _res.payload.res) or null
                    unless err
                        try clear-timeout x
                        set-state next-state
                    else
                        ctx.component.warn message: err
                        @set \check-state, \error
                        @set \checked, null


                if (@has-event 'statechange') or @get \async
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
                        if err is \timeout
                            ctx.component.warn message: "Async checkbox is timed out."
                            @set \check-state, \error
                            return
                        else
                            logger.error err, callback
                    else
                        #logger.clog "no error returned, setting checkbox to ", checked
                        set-state checked

                unless (@get \sync-topic or @has-event \statechange or @get \async)
                    # if not realtime or not async, then consider this as a simple checkbox
                    curr-state = @get \checked
                    set-state not curr-state

    data: ->
        checked: undefined
        'check-state': 'unchecked'
        transparent: no
        initial: null
        fps: 20Hz  # maximum refresh rate on realtime connections
