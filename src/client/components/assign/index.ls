component-name = "assign"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        try
            if @get \if-null
                # only update if output is null at the beginning
                #console.log "...update if null at the beginning..."
                output = @get \output
                if output not in [void, null, '']
                    #console.log "...but the output isnt null (#{@get 'output'})"
                    return
            @observe \input, (new-val, old-val) ->
                #console.log "ASSIGN: assigning new value: ", new-val
                @set \output, new-val
        catch
            debugger
