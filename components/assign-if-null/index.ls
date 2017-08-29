require! 'aea':{pack, unpack}

Ractive.components['assign-if-null'] = Ractive.extend do
    isolated: yes
    template: ''
    onrender: ->
        left = @get \left
        unless left
            left = @get \right
            @set \left, left
