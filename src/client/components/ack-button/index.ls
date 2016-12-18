
{sleep} = require "aea"

Ractive.components['ack-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        modal-error = $ @find \.modal-error

        modal-error.modal do
            keyboard: yes
            focus: yes
            show: no

        modal-confirmation = $ @find \.modal-confirmation

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

                if s in <[ info ]>
                    __.set \state, \info

                    @set \infoTitle, msg.title
                    @set \infoMessage, msg.message
                    modal-confirmation.modal \show
                    # TODO Reset `infoTitle` and `infoMessage` on modal dismiss

                __.set \selfDisabled, self-disabled

            confirm: (confirmation-obj, callback) ->
                @set \infoTitle, confirmationObj.title
                @set \infoMessage, confirmationObj.message
                @set \confirmationType, confirmationObj.type
                @set \confirmationCallback, callback
                modal-confirmation.modal \show

            # TODO What if confirmation modal dismissed?

            modalClosing: (ev, status) ->
                callback = @get \confirmationCallback
                callback status, this

                # Reset relevant props for next confirmation
                @set \confirmationType, null
                @set \confirmationCallback, null
                @set \confirmationInput, null
                modal-confirmation.modal \hide

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
