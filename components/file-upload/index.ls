require! 'dcs/browser':{Signal}
require! 'aea': {VLogger}
require! './csv-utils': {parse-csv}

'''
# Context API
-------------

Event Signature: (ctx, file, next) ->
    ctx.heartbeat(milliseconds): postpone the timeout error
    file: the uploaded file
        file.csv if file is csv type

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

                show-err = (err) ~>
                    @set \state, \error
                    @set \errMessage, err.message
                    reset-input!

                timeout = sleep 6000ms, ~>
                    show-err message: \Timeout!

                const c = ctx.getParent yes
                c.refire = yes
                c.logger = logger
                c.heartbeat = (_timeout) ~>
                    secs = _timeout / 1000
                    console.log "Upload button has heartbeat for #{secs} seconds."
                    try clear-timeout timeout
                    @set \state, \doing
                    timeout := sleep _timeout, ~>
                        show-err message: "Timeout for #{secs} seconds."


                reader = new FileReader!
                reader.onload = (e) ~>
                    data-url-signal.go e.target.result

                file_type = @get \type
                switch file_type
                | \binary => reader.readAsDataURL file
                | \text, \csv => reader.readAsText file
                |_ => ...

                reason, file-data <~ data-url-signal.wait
                csv = null
                # conversion is done
                <~ :lo(op) ~>
                    if file_type is \csv
                        err, res <~ parse-csv file-data, do
                            columns: @get \columns
                            delimiter: @get \delimiter
                        if err => return show-err err
                        csv := res
                        return op!
                    else
                        return op!
                value =
                    blob: file
                    base64: file-data.split ',' .1
                    raw: file-data
                    name: file.name
                    type: file.type     # content_type
                    file_type: file_type
                    preview-url: window.URL.createObjectURL file

                if csv
                    value.csv =
                        data: csv.column-list
                        columns: csv.columns

                err <~ @fire \choose, c, value
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
