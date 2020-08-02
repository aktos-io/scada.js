Ractive.components['input-field'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        number-units = """
            dakika saniye saat
            kg gr
            """
        unit = @get \unit
        if unit and unit.to-lower-case! in number-units.split ' '
            @set \type, \number

        if @get('type') is \number
            input = $ @find \input
            input.on \focus, (ev) ->
                $ this .on \mousewheel.disableScroll, (ev) ->
                    $ this .blur!

    data: ->
        type: \number
        unit: null
        value: null
        placeholder: ''
