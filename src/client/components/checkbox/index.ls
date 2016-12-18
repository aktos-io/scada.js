Ractive.components['checkbox'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        modal-error = $ @find \.modal-error

        modal-error.modal do
            keyboard: yes
            focus: yes
            show: no

        @observe \checked, (_new, _old) ->
            __.set \state, if _new then 'checked' else 'unchecked'

        @on do
            toggleChecked: ->
                __.set \timestamp, Date.now! 
                if __.get(\async)
                    if __.get(\checked) then
                        [curr-state, intended-state] = <[ checked unchecked ]>
                    else
                        [curr-state, intended-state] = <[ unchecked checked ]>
                    parameter = __.get(\value)

                    __.fire \statechange, {component: __}, curr-state, intended-state, parameter
                else
                    __.toggle \checked

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

                if s in <[ error ]>
                    __.set \reason, msg
                    modal-error.modal \show

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
        tooltip: ''
        timestamp: null
