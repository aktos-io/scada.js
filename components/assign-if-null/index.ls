Ractive.components['assign-if-null'] = Ractive.extend do
    isolated: yes
    template: ''
    onrender: ->
        unless @get \left
            @set \left, @get \right
