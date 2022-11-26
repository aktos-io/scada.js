'''

# Usage:
---------

attributes:
    tristate="true": display a "CLEAR" button, allow "checked" to be undefined/null
    route="mytopic" sync with "mytopic" in realtime

checked="{{value}}" : where the value is one of
    * true
    * false
    * null or undefined (for high impedance)

'''

require! 'aea/vlogger': {VLogger}

Ractive.components['checkbox'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    oninit: ->
        if @get \class
            if that.index-of(\transparent)  > -1
                @set \transparent, yes
        @debug = @get \debug

        if @getContext!.has-listener \select, yes
            @set \async, yes

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

        # observe `checked`
        @observe \checked, (val) ~>
            set-state val

        # visually update on init
        set-visual @get \checked


        @observe 'busy', (value) ~> 
            @set \check-state, if value 
                \doing            
            else
                if @get('checked') then \checked else \unchecked

        @observe 'error', (value) ~> 
            if value 
                @set \check-state, \error
            else 
                @set \check-state, if @get('checked') then \checked else \unchecked      

        @on do
            _statechange: (ctx) ->
                if (ctx.hasListener 'statechange') or @get \async
                    curr-check-state = @get \check-state
                    curr-checked = @get \checked

                    @set \check-state, \doing
                    checked = @get \checked

                    #logger.clog "sending handler the next check state: from", checked, "to", (not checked)
                    checked = not checked

                    const c = ctx.getParent yes
                    c.refire = yes
                    c.actor = ack-button.actor
                    err, callback <~ @fire \statechange, c, checked

                    if callback
                        console.warn "DEPRECATED: callback won't be supported anymore."
                        debugger

                    if err
                        # restore previous state
                        @set \check-state, curr-check-state
                        @set \checked, curr-checked
                        if err is \TIMEOUT
                            ctx.component.warn message: "Async checkbox is timed out."
                            @set \check-state, \error
                            return
                        else
                            logger.error err
                    else
                        #logger.clog "no error returned, setting checkbox to ", checked
                        set-state checked

                unless (ctx.has-listener \statechange or @get \async)
                    # if not realtime or not async, then consider this as a simple checkbox
                    curr-state = @get \checked
                    set-state not curr-state

    data: ->
        checked: undefined
        'check-state': 'unchecked'
        transparent: no
        initial: null
        busy: false
        tooltip: ''