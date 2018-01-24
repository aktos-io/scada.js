require! {
    './sleep': {sleep, clear-timer}
    './packing': {pack, unpack, clone, diff}
    './merge': {merge}
    './logger': {Logger}
    './formatting': {unix-to-readable, readable-to-unix}
    './convert-units': {convert-units}
    './vlogger': {VLogger}
}
require! 'prelude-ls': {chars, unchars, reverse}
require! './copy-to-clipboard': {copyToClipboard}

export function assert (condition, message)
    unless condition
        message = message or "Assertion failed"
        if (typeof Error) isnt void
            throw new Error message
        throw message  # Fallback


is-nodejs = ->
    if typeof! process is \process
        if typeof! process.versions is \Object
            if typeof! process.versions.node isnt \Undefined
                return yes
    return no


export obj-copy = (x) -> JSON.parse JSON.stringify x

export dynamic-obj = (...x) ->
    o = {}
    val = x.pop!
    key = x.pop!

    #console.log "key, val: ", x, key, val
    if key
        o[key] = val
    else
        return val
    dynamic-obj.apply this, (x ++ o)

export attach = (obj, key, val) ->
    if key of obj
        obj[key].push val
    else
        obj[key] = [val]


export tr-to-ascii = (x) ->
    _from = "çalışöğünisÇALIŞÖĞÜNİŞ"
    _to = "calisogunisCALISOGUNIS"

    exploded = chars x
    for ci of exploded
        for index, f of _from
            exploded[ci] = _to[index] if exploded[ci] is f
    unchars exploded

if make-tests=no
    tests =
        'ÖZDİLEK': "OZDILEK"
        "özdilek": "ozdilek"

    console.log "started tr-to-ascii tests"
    for w, c of tests
        if tr-to-ascii(w) isnt c
            console.log "tr-to-ascii of #{w} is #{tr-to-ascii w} but expecting #{c}"
            throw
    console.log "finished tr-to-ascii tests"

require! './ractive-var': {RactiveVar}

module.exports = {
    sleep, clear-timer
    merge
    Logger,
    pack, unpack, clone, diff 
    unix-to-readable, readable-to-unix
    assert
    obj-copy, dynamic-obj, attach
    copyToClipboard
    tr-to-ascii
    convert-units
    is-nodejs
    VLogger
    RactiveVar
}
