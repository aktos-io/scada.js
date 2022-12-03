Ractive.components['pushbutton'] = Ractive.extend do
    template: require('./index.pug')
    isolated: no
    onrender: ->
        button = $ @find \.ui.button
        turn = (state) ~>
            switch Boolean(state)
            | true => 
                @set \state, \pressed 
                @set \pressed, true 
            | false => 
                @set \state, \release 
                @set \pressed, false 

        @observe \pressed, (value) ~>
            if value?
                turn value

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


    data: ->
        pressed: undefined
        state: \doing
        'pressed-color': \green
        'released-color': \gray
