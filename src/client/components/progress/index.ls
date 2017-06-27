Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        type = switch @get \type
            | \circle   => that
            | \buble    => that
            | \vertical => \bubble
            | \fan      => that
            | \custom   => that
            |_          => \line

        @set \_type, type

    onrender: ->
        max = @get \max
        min = @get \min
        elem = @find \div

        data-attributes = $ elem .data!
        inner-type = @get \_type
        unless inner-type is \custom
            init-options = data-attributes <<< do
                preset: inner-type
        else
            x = @partials.svg .0
            init = data-attributes <<<< do
                type: \stroke
                path: x
            console.log "init is :", init
            init-options = init

        bar = new ldBar elem, init-options


        @observe \value, (_new) ->
            percent = (_new * 100 / (max - min))
            bar.set percent, animate=no

    data: ->
        max: 100
        min: 0
        value: null
        _type: \line
