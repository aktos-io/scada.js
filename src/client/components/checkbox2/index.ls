component = require \path .basename __dirname
Ractive.components[component] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @

        @observe \checked, (_new, _old) ->
            console.log "checked status changed: #{_new}"
            __.set \state, if _new then 'checked' else 'unchecked'

        @on do
            toggleChecked: ->
                curr-state = if __.get(\checked) then \checked else \unchecked
                parameter = __.get(\value)
                __.fire \statechange, {component: __}, curr-state, parameter

            statechange: (ev, msg) ->
                console.log "inner state change fired"

            state: (s, msg) ->
                self-disabled = no

                if s in <[ checked ]>
                    __.set \state, \checked
                    __.set \checked, yes

                if s in <[ unchecked ]>
                    __.set \state, \unchecked
                    __.set \checked, no

                if s in <[ doing ]>
                    __.set \state, \doing
                    self-disabled = yes

                /*
                if s in <[ error ]>
                    __.set \state, \error
                    __.set \reason, msg
                    console.warn "ack-button: ", msg
                    modal-error.modal \show
                */

                __.set \selfDisabled, self-disabled


    data: ->
        checked: no
        style: ''
        reason: ''
        type: "default"
        value: ""
        class: ""
        disabled: no
        self-disabled: no
        enabled: yes
        angle: 0
