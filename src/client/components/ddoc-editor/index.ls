require! 'livescript': lsc
require! 'prelude-ls': {camelize}
require! 'aea': {merge, make-design-doc, pack, logger}

# -------------------------------------------------
require! 'dcs/browser': {Actor, Signal}

class CouchProxy extends Actor
    (@db-name) ->
        super \CouchProxy
        @get-signal = new Signal!
        @all-signal = new Signal!
        @put-signal = new Signal!

        @topic = "db.#{@db-name}"
        @subscribe "#{@topic}.**"

        @on \data, (msg) ~>
            if \res of msg.payload
                err = msg.payload.err
                res = msg.payload.res

                # `get` message
                if msg.topic is "#{@topic}.get"
                    @get-signal.go err, res

                # `all` message
                if msg.topic is "#{@topic}.all"
                    @all-signal.go err, res

                # `put` message
                if msg.topic is "#{@topic}.put"
                    @put-signal.go err, res

    get: (doc-id, callback) ->
        @send {get: doc-id}, "#{@topic}.get"
        reason, err, res <~ @get-signal.wait 5_000ms
        err = {reason: \timeout} if reason is \timeout
        callback err, res

    all: (opts, callback) ->
        @send {all: opts}, "#{@topic}.all"
        reason, err, res <~ @all-signal.wait 5_000ms
        err = {reason: \timeout} if reason is \timeout
        callback err, res

    put: (doc, callback) ->
        @send {put: doc}, "#{@topic}.put"
        reason, err, res <~ @put-signal.wait 5_000ms
        err = {reason: \timeout} if reason is \timeout
        callback err, res


db = new CouchProxy \test
# -------------------------------------------------

Ractive.components['ddoc-editor'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        #console.log "ddoc editor initializing..."
        @log = new logger \ddoc-editor
        design-document = (@get \document)
        @set (camelize \design-document), design-document
        @on do
            listDesignDocuments: (ev) ->
                /*
                @log.log "getting doc"
                err, res <~ db.get \01ec95a0cc893779c1098aa6cf17144b
                @log.log "got doc: ", err, res
                */
                ev.component.fire \state, \doing
                err, res <~ db.all {startkey: "_design/", endkey: "_design0", +include_docs}
                return ev.component.fire \error, err.message if err
                @set \designDocuments, [..key for res]
                ev.component.fire \state, \done...

            get-design-document: (ev, value) ->
                ev.component.fire \state, \doing
                self = this
                # get the _auth design document
                console.log "DB is: ", db
                err, res <- db.get value
                return ev.component.fire \error, err.message if err

                console.log "Current _auth document: ", res
                ddoc = res
                ddoc.livescript = res.src
                self.set \documentId, ddoc._id
                self.set (camelize \design-document), ddoc
                ev.component.fire \state, \done...

            get-all-design-documents: (ev) ->
                # dump all design documents, useful for backup
                __ = @
                ev.component.fire \state, \doing
                err, res <- db.all {startkey: "_design/", endkey: "_design0", +include_docs}
                return ev.component.fire \error, err.message if err

                __.set \allDesignDocs, ["\n\n\# ID: #{..doc._id} \n\n #{JSON.stringify(..doc, null, 2)}" for res].join('')

                ev.component.fire \state, \done


            compileDesignDocument: (ev)->
                console.log "Compiling auth document..."
                ev.component.fire \state, \doing
                try
                    js = lsc.compile (@get \designDocument.livescript), {+bare, -header}
                    console.log "Compiled output: ", js
                    ev.component.fire \state, \done...
                catch err
                    js = err.to-string!
                    ev.component.fire \error, "See Output Textarea"
                @set \designDocument.javascript, js

            putDesignDocument: (ev, e) ->
                self = @
                ev.component.fire \state, \doing

                ddoc = self.get \designDocument
                new-id = self.get \documentId
                if new-id isnt ddoc._id
                    ev.component.fire \info, "Putting new design document!"
                    ddoc._id = new-id
                    delete ddoc._rev
                id = ddoc._id
                if id.split('/').1 is ''
                    return ev.component.fire \error, "Design document name cannot be empty: #{id}"
                ddoc-js = eval ddoc.javascript

                # convert special functions to strings
                try
                    ddoc.views = ddoc-js.views
                catch
                    ev.component.fire \error, "Did you compile your view?"
                    return
                ddoc.lists = ddoc-js.lists
                ddoc.validate_doc_update = ddoc-js.validate_doc_update
                ddoc.src = ddoc.livescript
                ddoc = make-design-doc ddoc
                console.log "Full document to upload: ", ddoc
                err, res <- db.put ddoc
                if err
                    ev.component.fire \error, err.message
                    console.error "Error uploading ddoc-src document: ", err
                    return

                console.log "ddoc-src document uploaded successfully", res

                # update _rev field for the following updates
                ddoc._rev = res.rev
                self.set \designDocument, ddoc
                ev.component.fire \state, \done...

    data: ->
        db: null
        design-document:
            _id: '_design/my-test-document'
            livescript: "testing"
            javascript: "compiled testing"

        allDesignDocs: ''
        designDocuments: []
        documentId: ''


/*

*/
