
{sleep} = require "aea"

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        modal-error = $ @find \.modal-error
        modal-confirmation = $ @find \.modal-confirmation

        modal-error.modal do
            keyboard: yes
            focus: yes
            show: no


        modal-confirmation.modal do
            keyboard: yes
            focus: yes
            show: no

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
                    __.set \reason, msg
                    modal-error.modal \show

                __.set \selfDisabled, self-disabled

            info: (msg) ->
                __ = @
                if typeof! msg is \String
                    msg = message: msg
                <- sleep 1000ms
                __.set \infoTitle, (msg.title or \info)
                __.set \infoMessage, (msg.message)
                __.set \confirmationType, null
                console.log "info title: ", (__.get \infoTitle)
                console.log "info message: ", (__.get \infoMessage)
                modal-confirmation.modal \show
                # TODO Reset `infoTitle` and `infoMessage` on modal dismiss

            yesno: (opt, callback) ->
                @set \infoTitle, (opt.title or 'o_O')
                @set \infoMessage, (opt.message or 'Are you sure?')
                @set \confirmationType, opt.type
                @set \confirmationCallback, callback
                modal-confirmation.modal \show
                # TODO What if confirmation modal dismissed?

            closeYesNo: (answer) ->
                callback = @get \confirmationCallback
                modal-confirmation.modal \hide
                callback answer

                # Reset relevant props for next confirmation
                @set \confirmationType, null
                @set \confirmationCallback, null
                @set \confirmationInput, null

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
