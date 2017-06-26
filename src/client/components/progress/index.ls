Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        # get type of progress bar
        type = if @get \circular
            \circle
        else if @get \half-circle
            \fan
        else if @get \vertical
            \line
        else if @get \custom
            \line
        else
            \line

        @set \type, type

    onrender: ->
        max = @get \max
        min = @get \min

        bar = new ldBar "\##{@_guid}", do
            "stroke": '#f00'


        @observe \value, (val) ->
            console.log "val is: ", val
            percent = (val * 100 / (max - min))
            console.log "percent is: ", percent
            bar.set percent

    data: ->
        max: 100
        min: 0
        value: 12
        type: \simple
