require! {
    './cca-pouchdb': {PouchDB, signup, make-design-doc, check-login, is-db-alive}
    './merge': {merge}
    './sleep': {sleep, after, clear-timer}
    './signal': {wait-for, timeout-wait-for, go, is-waiting}
    './debug-log': {debug-log, get-logger}
    './packing': {pack, unpack}
    './formatting': {unix-to-readable, readable-to-unix}
}

export function assert (condition, message)
    unless condition
        message = message or "Assertion failed"
        if (typeof Error) isnt void
            throw new Error message
        throw message  # Fallback


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


module.exports = {
    signup, PouchDB, make-design-doc, check-login, is-db-alive
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go, is-waiting
    debug-log, get-logger
    pack, unpack
    unix-to-readable, readable-to-unix
    assert
    obj-copy, dynamic-obj, attach
}
