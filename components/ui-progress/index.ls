Ractive.components['ui-progress'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        max = @get \max
        min = @get \min
        indicator = $ @find \.ui.progress

        indicator.progress do
            total: max
            min: min
            showActivity: no

        @observe \value, (_new) ->
            indicator.progress "set progress", _new

        @observe \max, (_new) ->
            indicator.progress "set total", _new
            indicator.progress "set progress", @get \value

    data: ->
        max: 100
        min: 0
        value: 0
