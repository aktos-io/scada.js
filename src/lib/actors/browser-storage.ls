require! './actor': {Actor}
require! 'aea': {sleep}

export class BrowserStorage extends Actor
    (@prefix) ->
        super "BrowserStorage-#{@prefix}"

    action: ->
        @s = local-storage

    set: (key, value) ->
        try
            @log.log "saving key: ", key, "value: ", value, JSON.stringify value
            @s.set-item "#{@name}-#{key}", JSON.stringify value
        catch
            err =
                title: "Browser Storage: Set"
                message:
                    "Error while saving key: ", key, "error is: ", e

            @log.err err.message
            <~ sleep 500ms  # maybe logger is not ready yet. wait a little bit.
            @send 'app.log.err', err

    del: (key) ->
        @s.remove-item "#{@name}-#{key}"

    get: (key) ->
        try
            if @s.get-item "#{@name}-#{key}"
                if that is "undefined"
                    return undefined
                else
                    JSON.parse that 
        catch
            @del key
            err =
                title: "Browser Storage: Get"
                message:
                    "Error while getting key: ", key, "err is: ", e

            @log.err err.message
            <~ sleep 500ms  # maybe logger is not ready yet. wait a little bit.
            @send 'app.log.err', err
