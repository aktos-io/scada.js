Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        type = switch @get \type
            | \circle   => that
            | \buble    => that
            | \vertical => \bubble
            | \fan      => that
            |_          => \line

        if @partials.progress
            @set \type, type=\custom

        @set \_type, type

    onrender: ->
        max = @get \max
        min = @get \min
        elem = @find \div

        scada-defaults =
            type: if @get \fill then that else \stroke

        data-attributes = scada-defaults <<< $ elem .data!

        inner-type = @get \_type
        unless inner-type is \custom
            init-options = data-attributes <<< do
                preset: inner-type
        else
            init-options = data-attributes <<<< do
                path: @partials.progress .0
            console.log "init is :", init-options

        bar = new ldBar elem, init-options


        @observe \value, (_new) ->
            percent = (_new * 100 / (max - min))
            bar.set percent, animate=no

    data: ->
        max: 100
        min: 0
        value: null
        _type: \line
