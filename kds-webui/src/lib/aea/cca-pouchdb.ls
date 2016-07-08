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


export function make-design-doc (obj)
    # convert functions to strings in design docs
    for p of obj
        try
            throw if typeof! obj[p] isnt \Object
            obj[p] = make-design-doc obj[p]
        catch
            if typeof! obj[p] is \Function
                    obj[p] = '' + obj[p]
    obj


/*
x =
    a: 1
    b: 2
    c:
        d: -> \naber

console.log "make design doc: ", make-design-doc x
*/
