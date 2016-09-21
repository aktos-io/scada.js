require! 'aea': {merge}

component-name = "db-img"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        __ = @
        img = $ @find \img
        db = @get \db
        src = @get \src # src is: document_name/attachment_name



        do get-img = ->
            src = __.get \src
            return unless src 
            if src is __.get \lastSrc
                console.log "db-img: same source, returning..."
                return
            __.set \lastSrc, src

            try
                [doc-name, att-name] = src.split '/'
                throw unless doc-name and att-name
                console.log "db-img getting: #{doc-name}/#{att-name}"
            catch
                console.log "db-img err: ", e
                img.attr \alt, "no src specified!"
                return


            console.log "db-img getting attachment: ", doc-name, ":::", att-name
            err, res <- db.get-attachment doc-name, att-name
            if err
                console.log "can not get attachment", err
                img.attr \alt, "IMG NOT FOUND"
            else
                console.log "db-img: here is the attachment: ", res
                img.attr \src, URL.createObjectURL new Blob [res], {type: "image/png"}

        @observe \db.lastChange, (n) ->
            console.log "last change is: ", n
            get-img!

        @observe \src, ->
            console.log "db-img src changed, retrying!"
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
