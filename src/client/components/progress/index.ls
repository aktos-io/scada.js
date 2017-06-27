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

        @set \_type, type

    onrender: ->
        max = @get \max
        min = @get \min

        elem = @find \div
        data-attributes = $ elem .data!
        console.log "data attributes: ", data-attributes
        bar = new ldBar elem, data-attributes

        @observe \value, (_new) ->
            percent = (_new * 100 / (max - min))
            bar.set percent, animate=no

    data: ->
        max: 100
        min: 0
        value: 12
        _type: \line
