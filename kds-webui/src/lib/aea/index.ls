require! {
    './cca-pouchdb-auth': {
        signup
        get-cookie
        login-with-token
    }
    './merge'
    './sleep': {
        sleep
    }
}

PouchDB = require \pouchdb
    ..plugin require \pouchdb-authentication

module.exports = {
    signup, PouchDB, get-cookie, login-with-token
    sleep,
    merge
}
