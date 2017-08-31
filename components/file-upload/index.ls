require! 'dcs/browser':{Signal}

Ractive.components['file-upload'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        file-input = $ @find "input[type='file']"
        data-url-signal = new Signal!
        file-input.on \change, ~>
            file = file-input.prop \files .0

            reader = new FileReader!
            reader.onload = (e) ~> data-url-signal.go e.target.result
            reader.readAsDataURL file

            reason, file-data <~ data-url-signal.wait
            @fire \choose, {}, do
                blob: file
                base64: file-data.split ',' .1
                name: file.name
                type: file.type
                preview-url: window.URL.createObjectURL file
            , @get \value

            @set \file-name, file.name
