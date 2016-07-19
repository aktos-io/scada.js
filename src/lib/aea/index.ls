require! {
    './cca-pouchdb': {PouchDB, signup, make-design-doc, check-login}
    './merge': {merge}
    './sleep': {sleep, after, clear-timer}
    './signal': {wait-for, timeout-wait-for, go, is-waiting}
    './debug-log': {debug-log, get-logger}
    './packing': {pack, unpack}
    './formatting': {unix-to-readable, readable-to-unix}
}


module.exports = {
    signup, PouchDB, make-design-doc, check-login
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go, is-waiting
    debug-log, get-logger
    pack, unpack
    unix-to-readable, readable-to-unix
}
