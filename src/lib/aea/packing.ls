export function pack x
    JSON.stringify x, (key, val) ->
        if typeof! val is \Function
            return val + ''  # implicitly convert to string
        #else if val is undefined  => return null # DO NOT DO THAT!
        val

export function unpack x
    JSON.parse x


export clone = (x) ->
    unpack pack x
