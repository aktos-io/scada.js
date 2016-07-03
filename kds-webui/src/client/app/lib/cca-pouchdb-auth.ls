PouchDB = require \pouchdb

export signup = (user, password, callback) ->
    require! \crypto

    salt = crypto.randomBytes(16).toString('hex')
    hash = crypto.createHash('sha1')
    hash.update(password + salt)
    password-sha = hash.digest('hex')

    /*
    db.signup user, password-sha, (err, res) ->
        try
            throw err if err
            console.log "#{user} is signed up..."
        catch
            console.log "error while signup...", e
    */

    users = new PouchDB "https://demeter:hPwZLjgITAlqk@demeter.cloudant.com/_users", skip-setup: yes

    new-user =
        _id: "org.couchdb.user:#{user}"
        name: user
        roles: []
        type: \user
        password_sha: password-sha
        salt: salt

    err, res <- users.put new-user
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
