PouchDB = require \pouchdb
require! 'jquery': $

export signup = (db, user, password, callback) ->
    require! \crypto

    salt = crypto.randomBytes(16).toString('hex')
    hash = crypto.createHash('sha1')
    hash.update(password + salt)
    password-sha = hash.digest('hex')

    new-user =
        _id: "org.couchdb.user:#{user}"
        name: user
        roles: []
        type: \user
        password_sha: password-sha
        salt: salt

    err, res <- db.put new-user
    callback err, res if callback


export get-cookie = ->
    console.log "Cookie: ", document.cookie


export login-with-token = (token) ->
    console.log "token is: ", token
