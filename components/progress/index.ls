require! 'aea': {merge}

Ractive.components['progress'] = Ractive.extend do
    template: require('./index.html')
    isolated: yes
    oninit: ->
        _type = @get \type

        if @partials.path or @get(\img)
            _type = \custom 

        @set \_type, _type

    onrender: ->
        max = @get \max
        min = @get \min
        elem = @find \div

        opts =
            type: \stroke 
            'stroke-width': @get \thickness
            'stroke': @get \color

        if @get("fill")?
            opts.type = \fill 
            if @get("fill") isnt \fill 
                opts.fill = @get('fill')

        # default configuration regarding to "type"
        bubble-preset = (speed=5) ~> 
            speed = 10 if speed is 0 
            return do 
                preset: \bubble
                type: \fill
                path: @get("path") or "M10 10L90 10L90 90L10 90Z"

                # data:ldbar/res,bubble(colorBk, colorBubble, count, duration)
                fill: "data:ldbar/res,bubble(#{@get 'color'},\#fff,50,#{10 - speed})"

        opts `merge` switch @get \_type
            when \custom =>
                if @get \img
                    cfg =
                        img: that
                        type: \fill

                    if @get \background
                        cfg.img2 = that
                    cfg
                else
                    path: @partials.path .0

            when \bubble => do
                bubble-preset(@get \speed)

            when \vertical => do 
                bubble-preset(0)
            else =>
                preset: that

        console.log "progress opts: ", opts 
        bar = new ldBar elem, opts

        padding-bottom = @get \padding-bottom
        padding-top = @get \padding-top
        @observe \value, (_new) ->
            if _new?
                percent = 100 * _new / (max - min)
                bar-percent = (_new * (100 - padding-bottom - padding-top) / (max - min)) + (padding-bottom)
                @set \percent, percent
                bar.set bar-percent, animate=no
            else
                console.warn "TODO: this should indicate an error: ", _new
                @set \percent, undefined
                bar.set undefined, animate=no

    data: ->
        max: 100
        min: 0
        value: null
        'padding-top': 0
        'padding-bottom': 0
        'pattern-size': 100
        thickness: 10
        speed: 5
        color: \blue
        path: null # See https://www.w3schools.com/graphics/svg_path.asp

        # Possible types: 
        # * line 
        # * vertical 
        # * bubble 
        # * fan 
        # * circle
        # * custom -> needs a partial named "path"
        # => add more (gradient, stripe): https://loading.io/progress/, Pattern Generator
        type: \line
