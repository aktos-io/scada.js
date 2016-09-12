require! 'aea': {merge}

component-name = "db-img"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        img = $ @find \img
        db = @get \db
        src = @get \src # src is: document_name/attachment_name

        [doc-name, att-name] = src.split '/'
        do get-img = ->
            err, res <- db.get-attachment doc-name, att-name
            if err
                console.log "can not get attachment", err
                img.attr \alt, "IMG NOT FOUND"
            else
                console.log "here is the attachment: ", res
                img.attr \src, URL.createObjectURL res

        @observe \db.lastChange, (n) ->
            console.log "last change is: ", n
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
