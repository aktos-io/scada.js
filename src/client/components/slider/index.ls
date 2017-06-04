require! 'nouislider'
require! 'aea': {merge}

Ractive.components['slider'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        __ = this
        slider = $ @find \.slider-inner
        slider-outer = $ @find \.slider

        type = if @get \range
            \range
        else
            \simple


        min = @get(\min) or 0
        max = @get(\max) or 100

        opts =
            start: min
            connect: \lower
            range:
                min: min
                max: max
            behaviour: \drag
            animate: no
            step: 0.1

        if type is \range
            opts `merge` do
                connect: yes
                start: [min, min]
                range:
                    min: [min]
                    max: [max]

        if @get \vertical
            slider.css do
                height: @get(\height) or '200px'

            slider-outer.css do
                'margin-bottom': '80px'

            opts `merge` do
                orientation: \vertical
                direction: \rtl

        if @get \opts
            opts `merge` @get(\opts)

        nouislider.create slider.0, opts
        slider-widget = slider.0.no-ui-slider

        if type is \simple
            @observe \value, (_new) ->
                slider-widget.set _new

            slider-widget.on \slide, (values, handle) ->
                val = values[handle]
                __.set \value, val

        else if type is \range
            @observe \lower-value, (_new) ->
                slider-widget.set [_new, @get(\upper-value)]

            @observe \upper-value, (_new) ->
                slider-widget.set [@get(\lower-value), _new]

            slider-widget.on \slide, (values, handle) ->
                __.set \lower-value, values.0
                __.set \upper-value, values.1
