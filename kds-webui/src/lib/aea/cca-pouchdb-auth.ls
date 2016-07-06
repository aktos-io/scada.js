PouchDB = require \pouchdb

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

/*
user = "batman"
passwd = "naber1"

err, res <- signup user, passwd
try
    throw err if err
    console.log "user is created: #{user}"
catch
    console.log "error creating user: ", e

throw "naber"
*/
