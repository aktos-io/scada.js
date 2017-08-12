require! 'prelude-ls': {join, split}

sep = '/'
export pack-id = (id) ->
    throw 'Not an array' unless typeof! id is \Array
    join sep, id

export unpack-id = (id-str) ->
    id = split sep, id-str
    throw 'Not an array' unless typeof! id is \Array
    id
