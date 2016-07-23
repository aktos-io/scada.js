{sleep} = require "aea"

component-name = "ack-button"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    oninit: ->
        __ = @
        @observe \state, (val) ->
            #console.log "State change dedected!", val
            if val == "waiting"
                rotate-icon!

        function rotate-icon
            #console.log "rotate function is starting... , test ractive: __" , __
            state-val = __.get \state
            #console.log "state-val: ", state-val
            __.animate {angle: 360degree}, {duration: 2000ms}
            .then ->
                __.set 'angle', 1
                if state-val == "waiting"
                    rotate-icon!
                #else
                #    console.log "rotate function is stopped..."

        @on do
            button-clicked: (val) ->
                #console.log "component detects button click with value: ", val
                #console.log "what I know is: ", @get \buttonclick
                @get \buttonclick <| val


    data: ->
        angle: 0

/*
states:
    waiting
    okey
    normal
    error
*/
