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

module.exports = {
    signup, PouchDB, make-design-doc, check-login, is-db-alive
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go, is-waiting
    debug-log, get-logger
    pack, unpack
    unix-to-readable, readable-to-unix
    assert 
}
