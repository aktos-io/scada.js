Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        indicator = $ @find \.ui.progress
        indicator.progress do
            duration: 200ms

        @observe \value, (_new) ->
            indicator.progress "set progress", _new

        @observe \max, (_new) ->
            indicator.progress "set total", _new
            indicator.progress "set progress", @get \value
