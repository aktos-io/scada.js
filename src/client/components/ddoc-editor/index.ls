require! 'livescript': lsc
require! 'prelude-ls': {camelize}
require! 'aea': {merge, make-design-doc}

component-name = "ddoc-editor"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    oninit: ->
        console.log "ddoc editor initializing..."
        db = @get \db
        design-document = (@get \document)
        @set (camelize \design-document), design-document
        @on do
            get-design-document: ->
                self = @
                # get the _auth design document
                console.log "DB is: ", db
                design-document = self.get camelize \design-document
                err, res <- db.get design-document._id
                if err
                    console.log "Can not get design document: ", err
                else
                    console.log "Current _auth document: ", res
                    ddoc = res
                    ddoc.livescript = res.src
                    self.set (camelize \design-document), ddoc

            put-new-design-document: ->
                self = @
                design-document = @get \designDocument
                delete design-document._rev
                console.log "Putting new design document: ", design-document
                err, res <- db.put design-document
                if err
                    console.log "Error putting design document: ", err
                else
                    console.log "Design document uploaded successfully...", res
                    self.fire camelize \get-design-document

            compileDesignDocument: ->
                console.log "Compiling auth document..."
                try
                    js = lsc.compile (@get \designDocument.livescript), {+bare, -header}
                    console.log "Compiled output: ", js
                catch
                    js = e.to-string!
                @set \designDocument.javascript, js

            putDesignDocument: ->
                self = @
                console.log "Putting design document!"
                console.log "Uploading design document..."
                ddoc = self.get \designDocument
                ddoc-js = eval ddoc.javascript
                # convert special functions to strings
                ddoc = ddoc `merge` ddoc-js
                ddoc.src = ddoc.livescript
                ddoc = make-design-doc ddoc
                console.log "Full document to upload: ", ddoc
                err, res <- db.put ddoc
                if err
                    console.log "Error uploading ddoc-src document: ", err
                else
                    console.log "ddoc-src document uploaded successfully", res
                # update _rev field for the following updates
                self.fire camelize \get-design-document
    data: ->
        db: null
        design-document:
            _id: '_design/my-test-document'
            livescript: "testing"
            javascript: "compiled testing"
