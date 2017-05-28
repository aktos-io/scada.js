
{sleep} = require "aea"

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        #console.log "guid of this instance is: #{@_guid}"

    onrender: ->
        __ = @
        modal-error = $ @find ".ui.basic.modal"

        logger = @root.find-component \logger

        @observe \tooltip, (new-val) ->
            __.set \reason, new-val

        @on do
            click: ->
                val = __.get \value
                # TODO: remove {args: val}
                @fire \buttonclick, {component: this, args: val}, val

            error: (msg) ->
                @fire \state, \error, msg

            state: (s, msg) ->
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

                if s in <[ error ]>
                    __.set \state, \error
                    __.set \reason, (msg.message or msg)
                    __.set \modalMessage, (msg.message or msg)
                    __.set \modalTitle, (msg.title or 'This is error')
                    logger.fire \showDimmed

                __.set \selfDisabled, self-disabled

            info: (msg) ->
                __ = @
                if typeof! msg is \String
                    msg = message: msg

                msg = if msg.message.html
                    message: msg.message.html


                <- sleep 1000ms
                __.set \infoTitle, (msg.title or \info)
                __.set \infoMessage, (msg.message)
                __.set \confirmationType, null
                #console.log "info title: ", (__.get \infoTitle)
                #console.log "info message: ", (__.get \infoMessage)
                modal-confirmation.modal \show
                # TODO Reset `infoTitle` and `infoMessage` on modal dismiss

            yesno: (opt, callback) ->
                message = if opt.message.html
                    opt.message.html
                else
                    opt.message

                @set \infoTitle, (opt.title or 'o_O')
                @set \infoMessage, (message or 'Are you sure?')
                @set \confirmationType, opt.type
                @set \confirmationCallback, callback
                modal-confirmation.modal \show
                # TODO What if confirmation modal dismissed?

            closeYesNo: (answer) ->
                __ = @
                callback = @get \confirmationCallback
                modal-confirmation.modal \hide
                <- sleep 1000ms
                callback answer

                # Reset relevant props for next confirmation
                __.set \confirmationType, null
                __.set \confirmationCallback, null
                __.set \confirmationInput, null

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
