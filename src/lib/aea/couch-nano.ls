require! 'prelude-ls': {flatten, join, split}
require! 'nano'
require! './debug-log': {logger}
require! 'colors': {bg-red}

export class CouchNano
    (@cfg) ~>
        @cookie = null
        @nano = nano @cfg.url
        @log = new logger "db:#{@cfg.database}"
        @username = @cfg.user.name
        @password = @cfg.user.password

    connect: (callback) ->
        @log.log "Authenticating as #{@username}"
        err, body, headers <~ @nano.auth @username, @password
        if err
            @log.log "error while authenticating: ", err
            return callback err, null

        if headers
            if headers['set-cookie']
                @log.log "session opened for #{@username}"
                @cookie = that
                @log.log "cookie is: #{@cookie}"
                @db = (require \nano) do
                    url: "#{@cfg.url}/#{@cfg.database}"
                    cookie: @cookie

                return callback null, 'ok'

        @log.log bg-red "unexpected response."
        return callback {text: "unexpected response"}, null


    save: (doc, callback) ->
        err, res <- @db.insert doc
        err = if err
            do
                reason: err.reason
                name: err.name
        callback err, res



if require.main is module
    test = new CouchNano do
        user:
            name: 'theseencedidesceepediven'
            password: '09b8c87f79bd2072dc7cb20bad67138f578d7a03'
        url: "https://aktos.cloudant.com"
        database: \test
    <~ test.connect

    i = 2
    <~ :lo(op) ~>
        err, res <~ test.save do
            _id: "hello#{i++}"
            val: 1

        return test.log.err "error while putting document: ", err if err
        test.log.log "success: ", res

        return op! if i > 10
        lo(op)

    test.log.log "all documents inserted"
