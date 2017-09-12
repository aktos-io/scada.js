require! 'dcs/browser': {RactiveActor}

Ractive.components['pushbutton'] = Ractive.extend do
    template: RACTIVE_PREPARSE("index.pug")
    isolated: no
    onrender: ->
        button = $ @find \.ui.button

        topic = @get \topic
        actor = new RactiveActor this, do
            name: \pushbutton
            topic: topic

        name-state = (state) ~>
            @set \state, if state
                \pressed
            else
                \released

        turn = (state) ~>
            @set \state, \doing
            err <~ @fire \toggle, {next-state: state}
            unless err
                name-state state

        @observe \pressed, (_new) ~>
            name-state _new

        @on do
            pressRelease: (ctx) ->
                debugger

        # for desktop
        button.on \mousedown, ->
            turn on
            button.on 'mouseleave', -> turn off

        button.on \mouseup, ->
            turn off
            button.off 'mouseleave'

        # for touch device
        button.on 'touchstart', (e) ->
            turn on
            button.on 'touchleave', -> turn off
            e.stop-propagation!

        button.on 'touchend', (e) ->
            turn off

        actor.on \data, (msg) ~>
            if msg.payload
                if that.curr
                    name-state that
                    @set \pressed, that

        if topic
            actor.request-update that 

    data: ->
        state: \doing
