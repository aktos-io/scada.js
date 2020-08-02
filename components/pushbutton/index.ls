require! 'actors': {RactiveActor}

Ractive.components['pushbutton'] = Ractive.extend do
    template: require('./index.pug')
    isolated: no
    oninit: ->
        @actor = new RactiveActor this, do
            name: \pushbutton

    onrender: ->
        button = $ @find \.ui.button
        name-state = (state) ~>
            @set \state, if state
                \pressed
            else
                \released

        turn = (state) ~>
            @set \state, \doing
            err <~ @fire \toggle, {@actor}, state
            unless err
                name-state state
            else
                @actor.send 'app.log.error', do
                    title: 'Pushbutton Error'
                    message: err
                @actor.log.err err

        @observe \pressed, (_new) ~>
            if typeof! _new isnt \Undefined
                name-state _new

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

        @actor.on \data, (msg) ~>
            curr = msg.data?.curr
            if curr?
                name-state curr
                @set \pressed, curr

        if @get \topic
            @actor.subscribe that
            #@actor.request-update that


    data: ->
        pressed: undefined
        state: \doing
        'pressed-color': \red
        'released-color': \green
