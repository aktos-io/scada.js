require! 'aea':{pack, unpack, merge}

Ractive.components['formal-field'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    onrender: ->
        __ = @

        @on do
            edit: ->
                __.set \editable, yes
                __.set \previous, unpack pack (__.get \curr)

            accept: (ev) ->
                curr = __.get \curr
                previous = __.get \previous
                log = __.get \log
                lg <- __.fire \test, ev, curr, previous
                lg.date= Date.now!
                log.push lg
                __.set \log, log.reverse!
                __.set \editable, no

            cancel: (ev) ->
                __.set \editable, no

    data: ->
        previous: ""
        editable: no
        curr: {}
        log: []
