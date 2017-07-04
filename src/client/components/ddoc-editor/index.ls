require! 'livescript': lsc
require! 'prelude-ls': {camelize}
require! 'aea': {merge, make-design-doc, pack, logger}

# -------------------------------------------------
require! 'dcs/browser': {Actor, Signal}

class CouchProxy extends Actor
    (@db-name) ->
        super \CouchProxy
        @get-signal = new Signal!

        @topic = "db.#{@db-name}"
        @subscribe "#{@topic}.**"

        @on \data, (msg) ~>

            if msg.topic is "#{@topic}.get" and \res of msg.payload
                @get-signal.go msg.payload.err, msg.payload.res



    get: (doc-id, callback) ->
        @send {get: doc-id}, "#{@topic}.get"

        reason, err, res <~ @get-signal.wait 10_000ms
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
            listDesignDocuments: (event, ev) ->
                @log.log "getting doc"
                err, res <~ db.get \01ec95a0cc893779c1098aa6cf17144b
                @log.log "got doc: ", err, res
                return




                __ = @
                ev.component.fire \state, \doing
                err, res <- db.all {startkey: "_design/", endkey: "_design0", +include_docs}
                return ev.component.fire \state, \error, err.message if err
                __.set \designDocuments, [..key for res]
                ev.component.fire \state, \done...

            get-design-document: (event, ev, value) ->
                ev.component.fire \state, \doing
                self = this
                # get the _auth design document
                console.log "DB is: ", db
                err, res <- db.get value
                return ev.component.fire \state, \error, err.message if err

                console.log "Current _auth document: ", res
                ddoc = res
                ddoc.livescript = res.src
                self.set \documentId, ddoc._id
                self.set (camelize \design-document), ddoc
                ev.component.fire \state, \done...

            get-all-design-documents: (event, ev) ->
                __ = @
                ev.component.fire \state, \doing
                err, res <- db.all {startkey: "_design/", endkey: "_design0", +include_docs}
                return ev.component.fire \state, \error, err.message if err

                __.set \allDesignDocs, ["\n\n\# ID: #{..doc._id} \n\n #{JSON.stringify(..doc, null, 2)}" for res].join('')

                ev.component.fire \state, \done


            compileDesignDocument: (event, e)->
                console.log "Compiling auth document..."
                e.component.fire \state, \doing
                try
                    js = lsc.compile (@get \designDocument.livescript), {+bare, -header}
                    console.log "Compiled output: ", js
                    e.component.fire \state, \done...
                catch err
                    js = err.to-string!
                    e.component.fire \state, \error, "See Output Textarea"
                @set \designDocument.javascript, js

            putDesignDocument: (event, e) ->
                self = @
                e.component.fire \state, \doing

                ddoc = self.get \designDocument
                new-id = self.get \documentId
                if new-id isnt ddoc._id
                    e.component.fire \info, "Putting new design document!"
                    ddoc._id = new-id
                    delete ddoc._rev
                id = ddoc._id
                if id.split('/').1 is ''
                    return e.component.fire \state, \error, "Design document name cannot be empty: #{id}"
                ddoc-js = eval ddoc.javascript

                # convert special functions to strings
                ddoc.views = ddoc-js.views
                ddoc.lists = ddoc-js.lists
                ddoc.validate_doc_update = ddoc-js.validate_doc_update
                ddoc.src = ddoc.livescript
                ddoc = make-design-doc ddoc
                console.log "Full document to upload: ", ddoc
                err, res <- db.save ddoc
                if err
                    e.component.fire \state, \error, err.message
                    console.error "Error uploading ddoc-src document: ", err
                    return

                console.log "ddoc-src document uploaded successfully", res

                # update _rev field for the following updates
                ddoc._rev = res.rev
                self.set \designDocument, ddoc
                e.component.fire \state, \done...

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
