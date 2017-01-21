Ractive.components['formal-field'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = @
        @on do
            edit: ->
                __.set \editable, yes

    data: ->
        editable: no
        value: ""
