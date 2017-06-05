ProgressBar = require 'progressbar.js'

Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        # get type of progress bar
        type = if @get \circular
            \circular
        else if @get \half-circle
            \half-circle
        else if @get \vertical
            \vertical
        else if @get \custom
            \custom
        else
            \simple

        @set \type, type

    onrender: ->
        max = @get \max
        min = @get \min

        try
            bar = new ProgressBar.Path "\##{@_guid}-progress .progress-path", do
                strokeWidth: 6
                color: '#FFEA82'
                trailColor: '#eee'
                trailWidth: 1
                svgStyle:
                    'height': '100px'
                    'width': '100px'
        catch
            console.error "progress: ", e
            return

        @observe \value, (val) ->
            bar.set (val / (max - min))

    data: ->
        max: 100
        min: 0
        value: 0
        type: \simple
