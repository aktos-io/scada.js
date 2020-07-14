require! 'aea': {merge}

Ractive.components['db-img'] = Ractive.extend do
    isolated: yes
    template: require('./index.pug')
    onrender: ->
        __ = @
        img = $ @find \img
        db = @get \db
        err-box = $ @find \span
        src = @get \src # src is: document_name/attachment_name


        if db is void
            #console.error "no database connection provided to db-img!"
            img.attr \alt, "IMG ERR: DB NOT FOUND (1)"
            return

        do get-img = ->
            src = __.get \src
            return unless src
            if src is __.get \lastSrc
                #console.log "db-img: same source, returning..."
                return
            __.set \lastSrc, src

            try
                [doc-name, att-name] = src.split '/'
                throw unless doc-name and att-name
                #console.log "db-img getting: #{doc-name}/#{att-name}"
            catch
                #console.log "db-img err: ", e
                img.attr \alt, "no src specified!"
                return


            #console.log "db-img getting attachment: ", doc-name, ":::", att-name
            err, res <- db.get-attachment doc-name, att-name
            if err
                #console.warn "can not get attachment", err
                img.attr \alt, "IMG NOT FOUND"
                err-box.text 'IMAGE NOT FOUND'
            else
                #console.log "db-img: here is the attachment: ", res
                img.attr \src, URL.createObjectURL new Blob [res], {type: "image/png"}

        @observe \db.lastChange, (n) ->
            #console.log "last change is: ", n
            get-img!

        @observe \src, ->
            #console.log "db-img src changed, retrying!"
            get-img!

        /*
        # Tested, working; but may be inefficient:
        # --------------------------
        err, res <- db.get 'mydoc', {+attachments, +include_docs}
        if err
            console.log "error getting mydoc: ", err
        else
            console.log "mydoc is: ", res

        img.attr \src, "data:img/png;base64, #{res._attachments.file.data}"
        */

    data: ->
        last-src: null
        db: ''
        error: no
        src: ''
