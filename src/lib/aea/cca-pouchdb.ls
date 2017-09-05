require! 'prelude-ls': {join}

#console.log "PouchDB adapters: ", PouchDB.adapters

export make-user-doc = (user) ->
    require! \crypto
    salt = crypto.randomBytes(16).toString('hex')
    hash = crypto.createHash('sha1')
    hash.update(user.passwd + salt)
    password-sha = hash.digest('hex')

    new-user =
        _id: "org.couchdb.user:#{user.name}"
        name: user.name
        roles: user.roles or []
        type: \user
        password_sha: password-sha
        salt: salt

# check whether we are logged in or not
export function check-login (db, callback)
    url = if db._db_name
        db._db_name
    else
        db.name

    try
        session-db = url.split '/'
            ..[session-db.length - 1] = '_session'
    catch
        console.error e
        debugger

    session-url = join "/" session-db
    #console.log "Checking sessoni with url: ", session-url
    $.ajax do
        type: \GET
        url: session-url
        xhrFields: {+withCredentials}
        headers:
            'Content-Type':'application/x-www-form-urlencoded'
        success: (data) ->
            try
                try
                    res = JSON.parse data
                catch
                    res = data
                throw "not logged in..." if res.user-ctx.name is null
                #console.log "We are already logged in as ", res.user-ctx.name
                callback false if typeof! callback is \Function
            catch
                console.log "Check login not succeeded: ", e?.to-string!, data
                callback true if typeof! callback is \Function

        error: (err) ->
            console.log "Something went wrong while checking logged in state: ", err
            callback true if typeof! callback is \Function

export function is-db-alive (db, callback)
    return unless db
    url = if db._db_name
        db._db_name
    else
        db.name

    try
        session-db = url.split '/'
            ..[session-db.length - 1] = '_session'
    catch
        console.error e
        debugger

    session-url = join "/" session-db

    $.ajax do
        type: \GET
        url: session-url
        headers:
            'Content-Type':'application/x-www-form-urlencoded'

        success: (data) ->
            #console.log "DB is alive: ", res
            callback err = false, data if typeof! callback is \Function

        error: (err) ->
            #console.log "Something went wrong while checking db status", err
            callback err = true if typeof! callback is \Function





charset = "0123456789" + "ACDEFHJKLMNPRTXYZ" # "abcdefhkmnrtxz"
/*
B, 8 -> 8
I, 1 -> 1
gjyp -> has tails, removed
i -> has dot, may be erased physically
Q, W, q w -> hard to pronounce
S -> can be confused by 5 in hand writing
*/

/*

function convertBase(value, from_base, to_base) {
  var range = charset.split('');
  var from_range = range.slice(0, from_base);
  var to_range = range.slice(0, to_base);

  var dec_value = value.split('').reverse().reduce(function (carry, digit, index) {
    if (from_range.indexOf(digit) === -1) throw new Error('Invalid digit `'+digit+'` for base '+from_base+'.');
    return carry += from_range.indexOf(digit) * (Math.pow(from_base, index));
  }, 0);

  var new_value = '';
  while (dec_value > 0) {
    new_value = to_range[dec_value % to_base] + new_value;
    dec_value = (dec_value - (dec_value % to_base)) / to_base;
  }
  return new_value || '0';
};

*/

convert-base = (value, from-base, to-base) ->
    range = charset.split ''
    from-range = range.slice 0, from-base
    to-range = range.slice 0, to-base

    dec-value = value.split '' .reverse!reduce ((carry, digit, index) ->
        if from-range.index-of(digit) is -1 then throw new Error "Invalid digit #{digit} for base #{from-base}."
        return carry += (from-range.index-of digit) * (Math.pow from-base, index)), 0

    new-value = ''
    while dec-value > 0
        new-value = to-range[dec-value % to-base] + new-value
        dec-value = (dec-value - (dec-value % to-base)) / to-base

    new-value or 0

export gen-entry-id = ->
    timestamp = new Date!get-time!
    random = Math.floor Math.random! * 1000

    stamp = "#{timestamp}#{random}"
    encoded = convert-base stamp, 10, 27
    decoded = convert-base encoded, 27, 10
    if decoded isnt stamp
        err = "Decoded (#{decoded}) and original input (#{stamp}) is not the same!"
        console.error err
        throw err

    return encoded


require! 'crypto'
require! 'bases'
require! 'prelude-ls': {take}

export hash8 = (inp) ->
    x = crypto.create-hash \sha256 .update inp .digest \base64
    y = bases.to-alphabet (bases.from-base64 x), charset
    take 8, y

export hash8n = (inp) ->
    hash = crypto.createHash('sha1')
    hash.update(inp)
    sha = hash.digest!

#console.log "Hash of hello world : ", hash8n "hello world"
