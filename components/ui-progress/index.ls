require! 'dcs': {sleep}

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
            autoSuccess: false
            precision: 3

        indicator.progress "set duration", 1ms # setting to 0ms is not working

        @observe \value, (_new) ->>
            indicator.progress "update progress", +_new

        @observe \max, (_new) ->
            indicator.progress "set total", +_new
            indicator.progress "update progress", +(@get \value)

        @observe \error, (error) -> 
            indicator.css("outline", if error then "3px dashed red" else "")
        

    data: ->
        max: 100
        min: 0
        value: 0
        error: null
