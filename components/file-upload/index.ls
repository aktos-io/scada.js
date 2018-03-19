require! 'dcs/browser':{Signal}
require! 'aea': {VLogger}


Ractive.components['file-upload'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        data-url-signal = new Signal!
        logger = new VLogger this

        @on do
            file-select: (ctx) ->
                keypath = ctx.resolve!
                file = ctx.node.files.0

                const c = ctx.getParent yes
                c.refire = yes
                c.logger = logger

                reader = new FileReader!
                reader.onload = (e) ~>
                    data-url-signal.go e.target.result
                reader.readAsDataURL file

                reason, file-data <~ data-url-signal.wait
                err <~ @fire \choose, c, do
                    blob: file
                    base64: file-data.split ',' .1
                    name: file.name
                    type: file.type
                    preview-url: window.URL.createObjectURL file

                unless err
                    @set \file-name, file.name

                # remove selected file so the same selection could trigger
                # "file-select" function
                @toggle \show
                @toggle \show
    data: ->
        show: yes
        tooltip: null
