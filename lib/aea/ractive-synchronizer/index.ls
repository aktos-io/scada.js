require! './get-vars': {get-vars}

export get-synchronizer = (loadingTpl) ->
    tpl-vars = get-vars loadingTpl
    #console.log "extracted loading template vars: ", tpl-vars 

    _macro = (handle, attrs) ->
        obj =
            observers: []
            update: (attrs) ->
                # debugger

            teardown: ->
                obj.observers.forEach (.cancel!)

        _orig = handle.template
        _orig.e += \ASYNC
        delete _orig.p

        orig = {v: 4, t: [_orig], e: {}}

        loading-template = loadingTpl or """
            <div class='ui yellow message'>
                We are fetching <b>#{handle.name}</b>...
            </div>
        """
        obj.observers.push handle.observe '@shared.deps._all', (val) ->
            if val
                handle.setTemplate(orig)
            else
                handle.setTemplate loading-template

        return obj

    return Ractive.macro _macro, {attributes: tpl-vars}
