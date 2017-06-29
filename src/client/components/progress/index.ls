Ractive.components['progress'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        type = switch @get \type
            | \circle   => that
            | \buble    => that
            | \vertical => that
            | \fan      => that
            |_          => \line

        if @partials.path or @get(\img)
            type = \custom
            @set \type,

        @set \_type, type

    onrender: ->
        max = @get \max
        min = @get \min
        elem = @find \div

        scada-defaults =
            type: if @get \fill then \fill else \stroke

        if @get \fill
            unless that is \fill
                console.log "fill is: ", @get('fill')
                scada-defaults <<< fill: that


        data-attr = $ elem .data!

        opts = scada-defaults <<< data-attr
        opts <<< switch @get \_type
            when \custom =>
                if @get \img
                    do
                        img: that
                        type: \fill
                else
                    path: @partials.path .0

            when \vertical => do
                preset: \buble
                type: \fill
                path: "M20 20L90 20L90 90L20 90Z"
                fill: 'data:ldbar/res,bubble(#248,#fff,50,1)'
            else =>
                preset: that

        bar = new ldBar elem, opts

        offset = @get \offset
        console.log "progress offset is #{offset}"
        @observe \value, (_new) ->
            bar-percent = (_new * (100 - offset) / (max - min)) + (offset)
            @set \percent, (_new * 100 / (max - min))
            bar.set bar-percent, animate=no

    data: ->
        max: 100
        min: 0
        value: null
        _type: \line
        offset: 0
