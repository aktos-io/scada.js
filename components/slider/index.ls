require! 'nouislider'
require! 'aea': {merge}

Ractive.components['slider'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        slider = @find \.slider

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

        /*
        if @get \vertical
            slider.css do
                height: @get(\height) or '200px'

            slider-outer.css do
                'margin-bottom': '80px'

            opts `merge` do
                orientation: \vertical
                direction: \rtl
        */

        if @get \opts
            opts `merge` @get(\opts)

        nouislider.create slider, opts
        
        @observe \disabled, (disabled) ~> 
            if disabled
                slider.setAttribute('disabled', true)
            else
                slider.removeAttribute('disabled')
        
        if type is \simple
            @observe \value, (_new) ~>
                slider.noUiSlider.set _new 

            slider.noUiSlider.on \slide, (values, handle) ~>
                val = values[handle]
                @set \value, val

        else if type is \range
            @observe \lower-value, (_new) ->
                slider.noUiSlider.set [_new, @get(\upper-value)]

            @observe \upper-value, (_new) ->
                slider.noUiSlider.set [@get(\lower-value), _new]

            slider.noUiSlider.on \slide, (values, handle) ~>
                @set \lower-value, values.0
                @set \upper-value, values.1
