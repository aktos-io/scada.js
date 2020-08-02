require! 'dcs/browser':{Signal, SignalBranch}
require! 'aea': {VLogger}
require! 'aea/csv-utils': {parse-csv}


Ractive.components['file-button'] = Ractive.extend do
    isolated: yes
    template: require('./index.pug')
    onrender: ->
        data-url-signal = new Signal!
        logger = new VLogger this

        unless @getContext!.has-listener \read, yes
            @set \disabled, yes
            return logger.error "file-button has no 'on-read' listener."

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
                    data-url-signal.go null, e.target.result

                file_type = @get \type
                switch file_type
                | \binary => reader.readAsDataURL file
                | \text, \csv => reader.readAsText file
                |_ => ...

                err, file-data <~ data-url-signal.wait
                value = null
                branch = new SignalBranch
                if err
                    value =
                        error: err
                else
                    csv = null
                    s2 = branch.add!
                    b2 = new SignalBranch
                    if file_type is \csv
                        s1 = b2.add!
                        err, res <~ parse-csv file-data, do
                            columns: @get \columns
                            delimiter: @get \delimiter
                        if err =>
                            b2.cancel!
                            branch.cancel!
                            return show-err err
                        csv := res
                        s1.go!
                    <~ b2.joined
                    filename = file.name.split '.'
                    extension = filename.pop!
                    basename = filename.join '.'
                    value :=
                        blob: file
                        base64: file-data.split ',' .1
                        raw: file-data
                        name: file.name
                        basename: basename
                        ext: extension
                        type: file.type     # content_type
                        file_type: file_type
                        preview-url: window.URL.createObjectURL file

                    if csv
                        value.csv =
                            data: csv.rows
                            columns: csv.columns
                    s2.go!
                err <~ branch.joined
                err <~ @fire \read, c, value
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
