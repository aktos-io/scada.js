Ractive.components['assign'] = Ractive.extend do
    template: ''
    onrender: ->
        @observe \right, (value) ~>
            @set \left, value
    data: ->
        left: null
        right: null

Ractive.components['assign-if-null'] = Ractive.extend do
    template: ''
    onrender: ->
        @observe \right, (value) ~>
            unless @get \left
                @set \left, value
    data: ->
        left: null
        right: null
