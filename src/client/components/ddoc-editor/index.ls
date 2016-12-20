require! 'livescript': lsc
require! 'prelude-ls': {camelize}
require! 'aea': {merge, make-design-doc, pack}

Ractive.components['ddoc-editor'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        #console.log "ddoc editor initializing..."
        db = @get \db
        design-document = (@get \document)
        @set (camelize \design-document), design-document
        @on do
            get-design-document: (e) ->
                e.component.fire \state, \doing
                self = this
                # get the _auth design document
                console.log "DB is: ", db
                design-document = self.get camelize \design-document
                err, res <- db.get design-document._id
                return e.component.fire \state, \error, err.message if err

                console.log "Current _auth document: ", res
                ddoc = res
                ddoc.livescript = res.src
                self.set (camelize \design-document), ddoc
                e.component.fire \state, \done...

            get-all-design-documents: (ev) ->
                __ = @
                ev.component.fire \state, \doing
                err, res <- db.all {startkey: "_design/", endkey: "_design0", +include_docs}
                return ev.component.fire \state, \error, err.message if err

                __.set \allDesignDocs, ["\n\n\# ID: #{..doc._id} \n\n #{JSON.stringify(..doc, null, 2)}" for res].join('')

                ev.component.fire \state, \done

            new-design-document: (e) ->
                __ = @
                e.component.fire \state, \doing
                design-document = @get \designDocument
                delete design-document._rev
                console.log "Putting new design document: ", design-document
                err, res <- db.save design-document
                return e.component.fire \state, \error, err.message if err

                console.log "Design document uploaded successfully...", res
                __.fire (camelize \get-design-document), e

            compileDesignDocument: (e)->
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

            putDesignDocument: (e) ->
                self = @
                e.component.fire \state, \doing
                console.log "Putting design document!"
                console.log "Uploading design document..."
                ddoc = self.get \designDocument
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
                else
                    console.log "ddoc-src document uploaded successfully", res
                    # update _rev field for the following updates
                    self.fire (camelize \get-design-document), e

    data: ->
        db: null
        design-document:
            _id: '_design/my-test-document'
            livescript: "testing"
            javascript: "compiled testing"

        allDesignDocs: ''
