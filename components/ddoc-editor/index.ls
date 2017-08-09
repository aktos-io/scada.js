require! 'livescript': lsc
require! 'prelude-ls': {camelize}
require! 'aea': {merge, make-design-doc, pack, logger}
# -------------------------------------------------

Ractive.components['ddoc-editor'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        @log = new logger \ddoc-editor
        if @get \db
            db = that
        else
            @log.err "db attribute is required!"
            return

        @on do
            listDesignDocuments: (ev) ->
                /*
                @log.log "getting doc"
                err, res <~ db.get \01ec95a0cc893779c1098aa6cf17144b
                @log.log "got doc: ", err, res
                */
                ev.component.fire \state, \doing
                err, res <~ db.all {startkey: "_design/", endkey: "_design0", +include_docs}
                if err
                    ev.component.fire \error, pack err
                    console.log "this is error on list design documents: ", err
                    return
                @set \designDocuments, [..key for res]
                ev.component.fire \state, \done...

            get-design-document: (ev, doc-id) ->
                ev.component.fire \state, \doing
                self = this
                # get the _auth design document
                err, res <- db.get doc-id
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
        design-document:
            _id: '_design/my-test-document'
            livescript: ""
            javascript: ""

        allDesignDocs: ''
        designDocuments: []
        documentId: ''
