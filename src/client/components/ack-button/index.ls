{sleep} = require "aea"

component-name = "ack-button"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        @observe \state, (val) ->
            #console.log "State change dedected!", val
            if val is \doing
                rotate-icon!
            if val isnt \error
                __.set \reason, ''


        @observe \tooltip, (new-val) ->
            __.set \reason, new-val

        function rotate-icon
            #console.log "rotate function is starting... , test ractive: __" , __
            state-val = __.get \state
            #console.log "state-val: ", state-val
            __.animate \angle, 360degree, {duration: 2000ms}
            .then ->
                __.set \angle, 0
                if state-val is \doing
                    rotate-icon!

        @on do
            click: ->
                val = __.get \value
                #console.log "ack-button detects button click with value: ", val

                # TODO: fix sending args twice!
                @fire \buttonclick, {component: this, args: val}, val

            state: (s, msg) ->
                if s in <[ ok done ]>
                    __.set \state, \done

                if s in <[ done... ok... ]>
                    __.set \state, \done
                    <- sleep 3000ms
                    __.set \state, ''

                if s in <[ doing ]>
                    __.set \state, \doing

                if s in <[ error ]>
                    __.set \state, \error
                    __.set \reason, msg

    data: ->
        __ = @
        angle: 0
        reason: ''
        type: "default"
        value: ""
        class: ""
        style: ""
        disabled: no
