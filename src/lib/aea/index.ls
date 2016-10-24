require! {
    './cca-pouchdb': {PouchDB, make-user-doc, make-design-doc, check-login, is-db-alive, gen-entry-id, hash8, hash8n}
    './merge': {merge}
    './sleep': {sleep, after, clear-timer}
    './signal': {wait-for, timeout-wait-for, go, is-waiting}
    './debug-log': {debug-log, get-logger}
    './packing': {pack, unpack}
    './formatting': {unix-to-readable, readable-to-unix}
    './couch-nano': {CouchNano}
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
    make-user-doc, PouchDB, make-design-doc, check-login, is-db-alive, gen-entry-id, hash8, hash8n
    CouchNano
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go, is-waiting
    debug-log, get-logger
    pack, unpack
    unix-to-readable, readable-to-unix
    assert
    obj-copy, dynamic-obj, attach
}
