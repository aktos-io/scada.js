Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        indicator = $ @find \.ui.progress

        max = @get \max
        min = @get \min
        indicator.progress do
            duration: 0
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
