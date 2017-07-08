export class BrowserStorage
    (@name) ->
        @s = local-storage

    set: (key, value) ->
        @s.set-item "#{@name}-#{key}", JSON.stringify value

    del: (key) ->
        @s.remove-item "#{@name}-#{key}"

    get: (key) ->
        JSON.parse @s.get-item "#{@name}-#{key}"
