require! {
    './cca-pouchdb': {signup, make-design-doc}
    './merge': {merge}
    './sleep': {sleep, after, clear-timer}
    './signal': {wait-for, timeout-wait-for, go}
    './debug-log': {debug-log}
    './packing': {pack, unpack}
}

PouchDB = require \pouchdb
    ..plugin require \pouchdb-authentication

module.exports = {
    signup, PouchDB, make-design-doc
    sleep, after, clear-timer
    merge
    wait-for, timeout-wait-for, go
    debug-log
    pack, unpack
}
