require! 'aea': {merge, sleep}

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        #console.log "guid of this instance is: #{@_guid}"

    onrender: ->
        __ = @
        modal-error = $ @find ".ui.basic.modal"

        # logger utility is defined here
        logger = @root.find-component \logger
        console.error "No logger component is found!" unless logger
        # end of logger utility


        @observe \tooltip, (new-val) ->
            __.set \reason, new-val

        @on do
            click: ->
                val = __.get \value
                # TODO: remove {args: val}
                @fire \buttonclick, {component: this, args: val}, val

            state: (event, s, msg, callback) ->
                self-disabled = no

                if s in <[ done ]>
                    __.set \state, \done

                if s in <[ done... ]>
                    __.set \state, \done
                    <- sleep 3000ms
                    if __.get(\state) is \done
                        __.set \state, ''

                if s in <[ doing ]>
                    __.set \state, \doing
                    self-disabled = yes

                __.set \selfDisabled, self-disabled

                if s in <[ error ]>
                    console.warn "scadajs: Deprecation: use \"ack-button.fire \\error\" instead"
                    @fire \error, msg, callback

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
        angle: 0
        reason: ''
        type: "default"
        value: ""
        class: ""
        style: ""
        disabled: no
        self-disabled: no
        enabled: yes
        state: ''
        info-title: ''
        info-message: ''
        confirmation-type: null
        confirmation-callback: null
        confirmation-input: null
        output: void
        modal-title: ''
        modal-message: ''
