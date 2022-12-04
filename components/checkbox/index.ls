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
        ack-button = @find-component \ack-button

        set-state = (state) ~>
            @set \checked, state
            @set \check_state, if state then \checked else \unchecked
            ack-button.fire \state, \done

        # observe `checked`
        @observe \checked, (val) ~>
            if val?
                set-state val

        @on do
            _statechange: (ctx) ->
                if (ctx.hasListener 'statechange') or @get \async
                    curr-check-state = @get \check_state
                    curr-checked = @get \checked

                    @set \check_state, \doing
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
                        @set \check_state, curr-check-state
                        @set \checked, curr-checked
                        if err 
                            @set \error, err 
                    else
                        #logger.clog "no error returned, setting checkbox to ", checked
                        set-state checked

                unless (ctx.has-listener \statechange or @get \async)
                    # if not realtime or not async, then consider this as a simple checkbox
                    curr-state = @get \checked
                    set-state not curr-state

    data: ->
        checked: undefined  # Boolean, input value 
        check_state: 'unchecked'
        transparent: no
        busy: null
        tooltip: ''
        error: null
