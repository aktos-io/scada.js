ProgressBar = require 'progressbar.js'

Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        # get type of progress bar
        type = if @get \circular
            \circular
        else if @get \vertical
            \vertical
        else
            \simple

        @set \type, type

    onrender: ->
        max = @get \max
        min = @get \min

        if @get(\type) is \simple
            indicator = $ @find \.ui.progress

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

        else if @get(\type) is \circular
            bar = new ProgressBar.Circle "\##{@_guid}-progress", do
                strokeWidth: 6
                color: '#FFEA82'
                trailColor: '#eee'
                trailWidth: 1
                svgStyle:
                    'height': '100px'
                    'width': '100px'

            @observe \value, (val) ->
                bar.set (val / (max - min))

    data: ->
        max: 100
        min: 0
        value: 0
        type: \simple
