require! 'prelude-ls': {flatten, join, split}
require! 'nano'
require! './debug-log': {logger}
require! 'colors': {bg-red, bg-green}

export class CouchNano
    (@cfg) ~>
        @cookie = null
        @nano = nano @cfg.url
        @log = new logger "db:#{@cfg.database}"
        @username = @cfg.user.name
        @password = @cfg.user.password
        @db-name = @cfg.database

    connect: (callback) ->
        @log.log "Authenticating as #{@username}"
        err, body, headers <~ @nano.auth @username, @password
        if err
            #@log.log "error while authenticating: ", err
            return callback err, null

        if headers
            if headers['set-cookie']
                #@log.log bg-green "session opened for #{@username}"
                @cookie = that
                #@log.log "cookie is: #{@cookie}"
                @db = (require \nano) do
                    url: @cfg.url
                    cookie: @cookie

                @request = @db.request

                return callback null, 'ok'

        @log.log bg-red "unexpected response."
        return callback {text: "unexpected response"}, null

    put: (doc, callback) ->
        err, res <- @request do
            db: @db-name
            body: doc
            method: \post

        err = {reason: err.reason, name: err.name} if err
        callback err, res

    get: (doc-id, opts, callback) ->
        [callback, opts] = [opts, {}] if typeof! opts is \Function

        err, res <- @request do
            db: @db-name
            doc: doc-id
            qs: opts

        err = {reason: err.reason, name: err.name} if err
        callback err, res



if require.main is module
    test = new CouchNano do
        user:
            name: 'theseencedidesceepediven'
            password: '09b8c87f79bd2072dc7cb20bad67138f578d7a03'
        url: "https://aktos.cloudant.com"
        database: \test
    <~ test.connect

    const i = 35
    count = 10
    _tmp = i

    ->
        <~ :lo(op) ~>
            err, res <~ test.put do
                _id: "hello#{_tmp++}"
                val: 1

            return test.log.err "error while putting document: ", err if err
            test.log.log "success: ", res

            return op! if _tmp > i + count
            lo(op)

        test.log.log "all documents are put"

    _tmp = i
    <~ :lo(op) ~>
        err, res <~ test.get "hello#{_tmp++}"
        return test.log.err "error while getting document: ", err if err
        test.log.log "success: ", res

        return op! if _tmp > i + count
        lo(op)

    test.log.log "all documents are read"
