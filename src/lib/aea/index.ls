require! {
    './cca-pouchdb': {PouchDB, signup, make-design-doc, check-login}
    './merge': {merge}
    './sleep': {sleep, after, clear-timer}
    './signal': {wait-for, timeout-wait-for, go, is-waiting}
    './debug-log': {debug-log}
    './packing': {pack, unpack}
}


module.exports = {
    signup, PouchDB, make-design-doc, check-login
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go, is-waiting
    debug-log
    pack, unpack
}
