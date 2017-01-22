require! 'aea':{merge, sleep}
require! 'csv-parse': parse
require! 'prelude-ls': {unique, map}

get-csv = (string, delimiter, callback) ->
    # http://csv.adaltas.com/parse/examples/
    err, res <- parse string, {comment: '#', delimiter: delimiter} #\t
    callback err, res

Ractive.components['csv-importer'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        __ = @
        ack-button = @find-component 'ack-button'
        delimiter = @get \delimiter
        console.warn "FIXME: remove: sleep 0"
        try
            columns = @get \columns .split ',' |> map (.trim!)
            for column in columns
                throw {message: "duplicate column name"} if columns.length isnt unique columns .length
                throw {message: "column name can not be null"} if column in [null, '', undefined]
        catch
            console.error "csv import:", e.message
            sleep 0, ->
                ack-button.fire \state, \error, e.message
            return

        @on do
            get-content: (ev) ->
                csv = @get \csv
                err, res <- get-csv csv, delimiter
                if err
                    return ev.component.fire \state, \error, "csv file isnt proper !!!"

                column-list = []
                unless res.length is 0
                    for imported in res
                        a = {}
                        if columns.length isnt imported.length
                            return ev.component.fire \state, \error, "columns can not match with given csv file's columns !!!"

                        for i, cell of imported
                            key = columns[i]
                            a[key] = cell

                        column-list.push a

                __.fire \import, {component: ack-button}, column-list

    data: ->
        csv: ""
        columns:""
