require! 'livescript': lsc
require! 'prelude-ls': {camelize, empty}
require! 'aea': {merge, pack, Logger, create-download}

make-design-doc = (obj) ->
    # convert functions to strings in design docs
    for p of obj
        try
            throw if typeof! obj[p] isnt \Object
            obj[p] = make-design-doc obj[p]
        catch
            if typeof! obj[p] is \Function
                    obj[p] = '' + obj[p]
    obj


Ractive.components['ddoc-editorASYNC'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        @log = new Logger \ddoc-editor
        if @get \db
            db = that
        else
            @log.err "db attribute is required!"
            return

        @on do
            listDesignDocuments: (ev) ->
                ev.component.fire \state, \doing
                err, res <~ db.all-docs {startkey: "_design/", endkey: "_design0", +include_docs}
                if err
                    ev.component.error pack err
                    console.log "this is error on list design documents: ", err
                    return
                docs = [..key for res]
                @set \designDocuments, docs
                console.log "got design docs: ", docs
                ev.component.fire \state, \done...

            get-design-document: (ctx, value, proceed) ->
                doc-id = value
                # get the _auth design document
                err, res <~ db.get doc-id
                if err
                    return proceed err

                console.log "Current _auth document: ", res
                ddoc = res
                ddoc.livescript = res.src
                @set \documentId, ddoc._id
                @set \designDocument, ddoc
                @set \getView_view, "#{ddoc._id.split '/' .1}/"
                proceed!

            dump-all-design-documents: (ev) ->
                # dump all design documents, useful for backup
                ev.component.fire \state, \doing
                err, res <~ db.all-docs {startkey: "_design/", endkey: "_design0", +include_docs}
                return ev.component.error err.message if err

                @set \allDesignDocs, JSON.stringify([..doc for res], null, 2)

                ev.component.fire \state, \done


            compileDesignDocument: (ev)->
                console.log "Compiling auth document..."
                ev.component?.fire \state, \doing
                try
                    js = lsc.compile (@get \designDocument.livescript), {+bare, -header}
                    console.log "Compiled output: ", js
                    ev.component?.fire \state, \done...
                catch err
                    js = err.to-string!
                    ev.component?.error "See Output Textarea"
                    @set \autoCompile, off
                @set \designDocument.javascript, js

            putDesignDocument: (ev, e) ->
                ev.component.fire \state, \doing
                if @get \autoCompile
                    @fire \compileDesignDocument

                ddoc = @get \designDocument
                new-id = @get \documentId
                creating-new = false
                if new-id isnt ddoc._id
                    ddoc._id = new-id
                    creating-new = true
                    delete ddoc._rev
                id = ddoc._id
                if id.split('/').1 is ''
                    return ev.component.error "Design document name cannot be empty: #{id}"
                ddoc-js = eval ddoc.javascript

                # convert special functions to strings
                try
                    ddoc.views = ddoc-js.views
                catch
                    ev.component.error "Did you compile your view?"
                    return
                ddoc.lists = ddoc-js.lists
                ddoc.validate_doc_update = ddoc-js.validate_doc_update
                ddoc.src = ddoc.livescript
                ddoc = make-design-doc ddoc
                console.log "Full document to upload: ", ddoc
                err, res <~ db.put ddoc
                if err
                    ev.component.error err.message
                    console.error "Error uploading ddoc-src document: ", err
                    return

                if creating-new
                    ev.component.info "Created new design document!"

                console.log "ddoc-src document uploaded successfully", res
                # update _rev field for the following updates
                ddoc._rev = res.rev
                @set \designDocument, ddoc
                ev.component.fire \state, \done...

            getView: (ctx) ->
                ctx.component.fire \state, \doing
                view = @get \getView_view
                params = @get \getView_params
                unless view => return ctx.component.error message: "View name is required."
                err, res <~ db.view view, params
                if err => return ctx.component.error err
                ctx.component.fire \state, \done...
                console.info "#{view} (#{JSON.stringify(params)}) results:", res

                @set \getView_result, """
                    {
                    #{["\t" + JSON.stringify(..) for res].join(',\n')}
                    }
                    """

            restoreDesignDocs: (ctx, file, next) ->
                docs = JSON.parse file.raw
                for ddoc in docs
                    if @get \restoreFromScratch
                        delete ddoc._rev
                    console.log "Design Doc: #{ddoc._id}, rev: #{ddoc._rev}"

                /* -------------------------------------------------------------
                THIS SEEMS A BUG WITH COUCHDB
                _bulk_docs api doesn't work with design documents when they are
                first uploaded to the db.

                Workaround: Put one design document for the first time, and then
                put the rest with _bulk_docs api.
                ------------------------------------------------------------- */
                # START OF WORKAROUND
                err, res <~ db.put docs.shift!
                if err => return next err
                # END OF WORKAROUND

                err, res <~ db.put docs
                if err => err = message: [..reason for res].join('\n')
                next err

            downloadBlueprints: (ctx) ->
                # dump all design documents, useful for backup
                ctx.component.fire \state, \doing
                err, res <~ db.all-docs {startkey: "_design/", endkey: "_design0", +include_docs}
                if err => return ctx.component.error err
                blueprints = [..doc for res]
                if empty blueprints
                    return ctx.component.error message: "No design documents found."
                create-download "design-docs.json", JSON.stringify(blueprints, null, 2)
                ctx.component.fire \state, \done...


    data: ->
        design-document:
            _id: '_design/my-test-document'
            livescript: ""
            javascript: ""

        allDesignDocs: ''
        designDocuments: []
        documentId: ''
        autoCompile: yes
        getView_params: {}
