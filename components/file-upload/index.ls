Ractive.components['file-upload'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        __ = @
        file-input = $ @find "input[type='file']"
        file = null
        file-input.on \change, ~>
            file := file-input.prop \files .0

            # preview file
            reader = new FileReader!
            reader.onload = (e) ~>
                file-data = e.target.result
                [prefix, data] = file-data.split ','
                # example prefix: data:image/png;base64
                @set \file-data, file-data
                @fire \choose, {}, do
                    blob: file
                    base64: data
                    name: file.name
                    prefix: prefix
                    type: file.type
                , @get \value

            reader.read-as-dataURL file

            @set \file-name, file.name

    data: ->
        filename: ''
