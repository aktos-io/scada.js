require! 'dcs/browser':{Signal}
require! 'aea': {VLogger}

'''
# Usage:
----------
Text file reading example:

    ```pug
        file-upload(on-choose="restoreDesignDocs" type="text") Upload!

    ```ls
        restoreDesignDocs: (ctx, file, next) ->
            docs = JSON.parse file.raw
            for ddoc in docs
                delete ddoc._rev
                console.log "Design Doc: #{ddoc._id}"
            err, res <~ db.put docs
            next err

'''

Ractive.components['file-upload'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        data-url-signal = new Signal!
        logger = new VLogger this

        reset-input = ~>
            # remove selected file so the same selection could trigger
            # "file-select" function
            @toggle \show
            @toggle \show

        @on do
            file-select: (ctx) ->
                keypath = ctx.resolve!
                file = ctx.node.files.0

                @set \state, \doing
                @set \errMessage, null

                timeout = sleep 6000ms, ~>
                    @set \state, \error
                    @set \errMessage, "Timeout"
                    reset-input!

                const c = ctx.getParent yes
                c.refire = yes
                c.logger = logger

                reader = new FileReader!
                reader.onload = (e) ~>
                    data-url-signal.go e.target.result

                switch @get("type")
                | \binary => reader.readAsDataURL file
                | \text => reader.readAsText file
                |_ => ...

                reason, file-data <~ data-url-signal.wait
                err <~ @fire \choose, c, do
                    blob: file
                    base64: file-data.split ',' .1
                    raw: file-data
                    name: file.name
                    type: file.type
                    preview-url: window.URL.createObjectURL file

                try clear-timeout timeout
                unless err
                    @set \file-name, file.name
                    @set \state, \done
                    <~ sleep 3000ms
                    @set \state, null
                else
                    @set \state, \error
                    @set \errMessage, ((try err.message) or err)

                reset-input!
    data: ->
        show: yes
        tooltip: null
        type: \binary
        state: ''
        errMessage: null
        doingTimer: null
