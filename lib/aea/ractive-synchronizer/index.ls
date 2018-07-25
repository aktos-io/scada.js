window.get-synchronizer = (placeholder) ->
    if placeholder and typeof! placeholder isnt \String
        throw new Error "placeholder MUST be the component's name"

    return Ractive.macro (handle, attrs) ~>
        obj =
            observers: []
            update: (attrs) ->
                # debugger

            teardown: ->
                obj.observers.forEach (.cancel!)

        _orig = handle.template
        delete _orig.p
        orig = {v: 4, t: [_orig], e: {}}

        mod-comp = (name) ->
            _orig.e = name
            return orig

        obj.observers.push handle.observe '@shared.deps._all', (val) !->
            console.log "#{handle.name} instance received a signal: #{JSON.stringify val}"
            if val
                handle.setTemplate mod-comp "#{handle.name}ASYNC"
            else
                ph = placeholder or "#{handle.name}LOADING"
                if Ractive.components[ph]
                    handle.setTemplate mod-comp ph
                else
                    handle.setTemplate """
                        <div class='ui yellow message'>
                            We are fetching <i>#{handle.name}</i>
                        </div>
                        """
        return obj
