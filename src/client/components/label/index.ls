require! 'aea/formatting': {displayFormat}

Ractive.defaults.data.displayFormat = displayFormat

Ractive.components['label'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        @observe \value, (_new) ->
            f = @get('displayFormat') '###.##', _new
            @set \formattedValue, f.fullText
    data: ->
        formattedValue: "123.45 hello/hour"
