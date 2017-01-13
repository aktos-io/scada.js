require! 'aea':{sleep}
require

Ractive.components['file-read'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        __ = @
        file-input = $ @find "input[type='file']"
        ack-button = @find-component 'ack-button'
        x = file-input.prop \files
        file-input.on \change, ->
            files = file-input.prop \files
            __.set \files, files

            # read files
            read-as = __.get 'read-as'
            reader = new FileReader!
            i = files.length
            <- :lo(op) ->
                return op! if i is 0
                file = files[* - i]
                console.log "reading files..."
                reader.onload = (e) ->
                    content = e.target.result
                    #console.log "file content is: ", content
                    console.log "read file: ", file.name

                    <- __.fire \read, {component: ack-button}, do
                        name: file.name
                        content: content
                    --i
                    lo(op)

                console.log "reading file: ", file
                switch read-as
                | 'base64' => reader.read-as-dataURL file
                |_ => reader.read-as-text file

            console.log "finished reading files..."
            file-input.prop \files, x 

    data: ->
        files: []
