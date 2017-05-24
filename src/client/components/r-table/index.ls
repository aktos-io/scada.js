require! aea: {sleep}

Ractive.components['r-table'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes

    oninit: ->
        @on do
            updateColNames: ->
                cols = $ @find 'thead > tr:last-of-type' .children!

                if cols.length is 0
                    console.error "Column names are not found, missing thead > tr > th?"
                col-names = [..inner-text for cols]
                $ @find 'tbody' .children \tr .each (i, row) ->
                    $ row .children \td .each (i, col) ->
                        $ col .attr \data-th, col-names[i]

    onrender: ->
        #r-table = @find \table.rwd-table
        #r-table.parent-element.client-width
        parent-width = ($ @find \.rwd-table).parent().width()
        #$ @find \.rwd-table .width(parent-width)
        width = $ @find \.rwd-table .width()
        @set \width, width


    oncomplete: ->
        @observe \update, ->
            __ = @
            <- sleep 50ms
            __.fire \updateColNames
