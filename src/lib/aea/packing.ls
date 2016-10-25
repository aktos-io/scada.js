export function pack x
    JSON.stringify x, (key, val) ->
        if typeof! val is \Function
            return val + ''  # implicitly convert to string
        val

export function unpack x
    try
        JSON.parse x
    catch
        console.error "Error while unpacking: #{e}, param: ", x
        #debugger
        throw e 
