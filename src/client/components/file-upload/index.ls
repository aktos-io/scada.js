require! 'aea': {merge}

component-name = "file-upload"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        p = $ @find \p
        file-input = $ @find \input
        img-preview = $ @find '.preview > img'
        img-verify = $ @find '.verify > img'
        db = @get \db

        p.text "This is the file input"

        file-input.on \change, ->

            file = file-input.prop \files .0
            console.log "file is: ", file


            # preview file
            reader = new FileReader!
            reader.onload = (e) ->
                img-preview.attr \src, e.target.result
            reader.read-as-dataURL file



            doc =
                _id: 'mydoc'
                _attachments:
                  "file":
                    type: file.type
                    data: file

            err, res <- db.get \mydoc
            if not err
                console.log "updating revision: ", res
                doc._rev = res._rev

            err, res <- db.put doc

            if err
                console.log "err: ", err
            else
                console.log "ok: ", res


            console.log "file is: ", file


            err, res <- db.get-attachment \mydoc, \file
            if err
                console.log "can not get attachment", err
            else
                console.log "here is the attachment: ", res

            img-verify.attr \src, URL.createObjectURL res


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
