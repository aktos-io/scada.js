require! 'aea/formatting': {displayFormat, parse-format}

Ractive.components['formatter'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        format = @get \format
        unless format
            console.error "Format is required to use a label!"
            return

        parse-format = @get \parseFormat
        format-obj = parse-format format
        display-format = @get \displayFormat

        @observe \value, (_new) ->
            f = displayFormat format-obj, _new
            @set \formattedValue, f.fullText
    data: ->
        formattedValue: ""
