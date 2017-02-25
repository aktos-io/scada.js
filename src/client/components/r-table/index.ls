
Ractive.components['r-table'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        #r-table = @find \table.rwd-table
        #r-table.parent-element.client-width
        parent-width = ($ @find \.rwd-table).parent().width()
        #$ @find \.rwd-table .width(parent-width)
        width = $ @find \.rwd-table .width()
        @set \width, width

        
    oncomplete: ->
        cols = $ @find 'thead > tr:last-of-type' .children!
        col-names = [..inner-text for cols]
        $ @find 'tbody' .children \tr .each (i, row) ->
            $ row .children \td .each (i, col) ->
                $ col .attr \data-th, col-names[i]
