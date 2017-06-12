require! 'aea': {merge, sleep}
require! 'aktos-dcs/src/io-actor': {IoActor}

Ractive.components['rt-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        debugger
        @actor = new IoActor \hello
        @actor.ractive = this
        @actor.sync \value

    onrender: ->
        __ = @

        # logger utility is defined here
        logger = @root.find-component \logger
        console.error "No logger component is found!" unless logger
        # end of logger utility

        @on do
            click: ->
                val = @get \value
                debugger


            error: (event, msg, callback) ->
                msg = {message: msg} unless msg.message
                msg = msg `merge` {
                    title: msg.title or 'This is my error'
                    icon: "warning sign"
                }
                @set \state, \error
                @set \reason, msg.message
                @set \selfDisabled, no
                action <- logger.fire \showDimmed, msg, {-closable}
                #console.log "error has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function

            info: (event, msg, callback) ->
                msg = {message: msg} unless msg.message
                msg = msg `merge` {
                    title: msg.title or 'ack-button info'
                    icon: "info circle"
                }
                action <- logger.fire \showDimmed, msg, {-closable}
                #console.log "info has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function

            yesno: (event, msg, callback) ->
                msg = {message: msg} unless msg.message
                msg = msg `merge` {
                    title: msg.title or 'Yes or No'
                    icon: "map signs"
                }
                action <- logger.fire \showDimmed, msg, {-closable, mode: \yesno}
                #console.log "yesno dialog has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function

    data: ->
        __ = @
        reason: ''
        type: "default"
        value: ""
        class: ""
        style: ""
        disabled: no
        self-disabled: no
        enabled: yes
        state: ''
        on-done: -> console.warn "default ack-button on-done function run"
        transparent: no
