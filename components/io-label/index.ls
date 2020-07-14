require! 'aea/formatting': {displayFormat, parse-format}

Ractive.defaults.data.displayFormat = displayFormat
Ractive.defaults.data.parseFormat = parseFormat

Ractive.defaults.data.formatter = (format, value) ->
    displayFormat (parseFormat format), value .fullText

Ractive.components['io-label'] = Ractive.extend do
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
