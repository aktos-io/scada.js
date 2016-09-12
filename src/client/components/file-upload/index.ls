component-name = "file-upload"
Ractive.components[component-name] = Ractive.extend do
    isolated: yes
    template: "\##{component-name}"
    onrender: ->
        __ = @
        file-input = $ @find "input[type='file']"
        img-preview = $ @find '.preview > img'
        db = @get \db

        unless @get \doc_id
            @set \doc_id, \mydoc

        file = null

        file-input.on \change, ->
            file := file-input.prop \files .0

            # preview file
            reader = new FileReader!
            reader.onload = (e) ->
                img-preview.attr \src, e.target.result
            reader.read-as-dataURL file

            __.set \attachment_name, file.name

        @on do
            upload-file: (e) ->
                console.log "uploading!!!"
                e.component.set \state, \doing

                filename = __.get \attachment_name
                doc_id = __.get \doc_id

                err, res <- db.get doc_id
                if not err
                    console.log "updating revision: ", res

                err, res <- db.put-attachment doc_id, filename, res._rev, file, file.type
                if err
                    console.log "err: ", err
                    e.component.set \state, \err
                    e.component.set \reason, err
                else
                    console.log "ok: ", res
                    __.set \filename, "#{doc_id}/#{filename}"
                    e.component.set \state, \done
