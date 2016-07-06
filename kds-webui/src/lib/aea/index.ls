{sleep} = require './aea'
{signup} = require './cca-pouchdb-auth'

PouchDB = require \pouchdb
    ..plugin require \pouchdb-authentication

module.exports = {
    sleep, signup, PouchDB
}
