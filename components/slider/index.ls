require! 'nouislider'
require! 'aea': {merge, sleep}

Ractive.components['slider'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        slider = @find \.slider

        type = if (@get \value2)?
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
            # see https://refreshless.com/nouislider/slider-options/#section-orientation
            slider.style.height = @get(\height) or '200px'
            opts `merge` do
                orientation: \vertical
                direction: @get(\direction) or \rtl

        if @get \direction 
            opts.direction = that 

        if @get \opts
            opts `merge` that

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
            @observe \value, (_new) ->
                slider.noUiSlider.set [_new, @get(\value2)]

            @observe \value2, (_new) ->
                slider.noUiSlider.set [@get(\value), _new]

            slider.noUiSlider.on \slide, (values, handle) ~>
                @set \value, values.0
                @set \value2, values.1
