Ractive.components['file-upload'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        file-input = $ @find "input[type='file']"
        file-input.on \change, ~>
            file = file-input.prop \files .0

            # preview file
            reader = new FileReader!
            reader.onload = (e) ~>
                file-data = e.target.result
                preview-url = window.URL.createObjectURL file
                @fire \choose, {}, do
                    blob: file
                    base64: file-data.split ',' .1
                    name: file.name
                    type: file.type
                    preview-url: preview-url
                , @get \value

                @set \file-name, file.name
                
            reader.read-as-dataURL file
