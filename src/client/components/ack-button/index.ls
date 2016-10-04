{sleep} = require "aea"
require! "randomstring":random

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
            if val isnt \error
                __.set \reason, ''


        tooltip-id = @get \tooltipId

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
                console.log "ack-button detects button click with value: ", val
                @fire \buttonclick, {component: this, args: val}
    data: ->
        angle: 0
        reason: ''
        tooltip-id: random.generate {length: 4}
        type: ""
        value: ""
        class: ""
