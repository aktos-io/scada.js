require! './debug-log': {logger: Logger}

export class BrowserStorage
    (@name) ->
        @s = local-storage
        @logger = new Logger \BrowserStorage

    set: (key, value) ->
        try
            @s.set-item "#{@name}-#{key}", JSON.stringify value
        catch
            @logger.err "Error while saving key: ", e

    del: (key) ->
        @s.remove-item "#{@name}-#{key}"

    get: (key) ->
        try
            JSON.parse @s.get-item "#{@name}-#{key}"
        catch
            @logger.err "Error while getting key: ", e
