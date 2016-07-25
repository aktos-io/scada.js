{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"

random = require \randomstring

component-name = "ack-button"
Ractive.components[component-name] = Ractive.extend do
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

    template: "\##{component-name}"
    data: ->
        angle: 0

/*
states:
    waiting
    okey
    normal
    error
*/
