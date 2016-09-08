{sleep} = require "aea"

component-name = "ack-button"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        @observe \state, (val) ->
            #console.log "State change dedected!", val
            if val is \doing
                rotate-icon!

        function rotate-icon
            #console.log "rotate function is starting... , test ractive: __" , __
            state-val = __.get \state
            #console.log "state-val: ", state-val
            __.animate {angle: 360degree}, {duration: 2000ms}
            .then ->
                __.set \angle, 0
                if state-val is \doing
                    rotate-icon!

        @on do
            myclick: (val) ->
                #console.log "ack-button detects button click with value: ", val
                @fire \buttonclick, val, {component: this}


    data: ->
        angle: 0
