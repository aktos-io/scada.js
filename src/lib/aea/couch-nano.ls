require! 'prelude-ls': {
    flatten
}
require! 'superagent': request

/*

user:
    name: ...
    password: ...
*/

export class CouchNano
    (cfg) ~>
        @cfg = cfg
        @db = null
        @cookie = null
        @user = null
        @_db = null # original nano database object

    check-session: (callback) ~>
        conn = nano @cfg.url
        err, ctx <- conn.session
        return console.error "Err: ", err if err
        debugger

        console.log "ctx: ", ctx

    close-session: (callback) ~>
        callback!

        conn = nano @cfg.url
        conn.request {
            db: '_session'
            method: 'delete'
            params: {}
            }, callback


    open-session: (callback) ~>
        __ = @
        request
            .post "#{__.cfg.url}/_session"
            #.get "#{__.cfg.url}/_session"
            .set 'Content-type', 'application/json'
            .send do
                name: __.cfg.user.name
                password: __.cfg.user.password
            .end (err, res) ->
                debugger
                request
                    #.set 'Access-Control-Allow-Credentials', 'true'
                    .with-credentials!
                    .end (err, res) ->
                        debugger

        return
        conn = nano do
            url: @cfg.url
            requestDefaults:
                jar: yes

        err, body, headers <- conn.auth @cfg.user.name, @cfg.user.password
        return console.log "err", err if err
        debugger
        if headers and headers.\set-cookie
            @cookie = headers.\set-cookie
            callback err=null, @cookie
        else
            console.error "We got no cookie?", headers

    use-session: (cookie, callback) ~>
        __ = @

        if typeof cookie is \function
            callback = cookie
            cookie = null

        cookie = flatten [cookie]

        @sconn = nano do
            url: @cfg.url
            cookie: @cookie or cookie

        err, ctx <- @sconn.session
        return console.error "Err: ", err if err

        console.log "ctx: ", ctx
        __.user = ctx.user-ctx
        __._db = __.sconn.use \domates
        #db.gen-entry-id = gen-entry-id

        callback err=no, ctx

    save-session: ~>
    get-session: ~>

    save: (docs) ~>


if require.main is module
    # here goes nodejs module
    1
