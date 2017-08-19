export class BrowserStorage
    (@name) ->
        @s = local-storage

    set: (key, value) ->
        try
            @s.set-item "#{@name}-#{key}", JSON.stringify value
        catch
            console.warn "FIXME: This is a workaround for iphone5s. Provide a fallback (to cookie?)"

    del: (key) ->
        @s.remove-item "#{@name}-#{key}"

    get: (key) ->
        JSON.parse @s.get-item "#{@name}-#{key}"
