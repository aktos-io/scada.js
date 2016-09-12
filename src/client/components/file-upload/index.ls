require! 'aea': {merge}

component-name = "file-upload"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        __ = @
        p = $ @find \p
        file-input = $ @find "input[type='file']"
        img-preview = $ @find '.preview > img'
        db = @get \db

        @set \docId, \mydoc

        p.text "This is the file input"

        file = null

        file-input.on \change, ->
            console.log "changed file input..."

            file := file-input.prop \files .0
            console.log "file is: ", file


            # preview file
            reader = new FileReader!
            reader.onload = (e) ->
                img-preview.attr \src, e.target.result
            reader.read-as-dataURL file

            x = "mydoc/#{file.name}"
            console.log "setting filename: ", x
            __.set \filename, x


        @on do
            upload-file: (e) ->
                console.log "uploading!!!"
                e.component.set \state, \doing

                doc =
                    _id: __.get \docId
                    _attachments:
                      "#{file.name}":
                        content_type: file.type
                        data: file

                err, res <- db.get doc._id
                if not err
                    console.log "updating revision: ", res
                    doc._rev = res._rev

                attachment = doc._attachments[file.name]

                err, res <- db.put-attachment doc._id, file.name, res._rev, attachment.data, attachment.type
                #err, res <- db.put doc

                if err
                    console.log "err: ", err
                    e.component.set \state, \err
                    e.component.set \reason, err
                else
                    console.log "ok: ", res
                    e.component.set \state, \done
