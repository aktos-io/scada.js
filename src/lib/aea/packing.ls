export function pack x
    JSON.stringify x, (key, val) ->
        if typeof! val is \Function
            return val + ''  # implicitly convert to string
        val

export function unpack x
    try
        JSON.parse x
    catch
        throw "Error while unpacking: #{e}"
