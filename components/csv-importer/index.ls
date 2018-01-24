require! 'aea':{merge, sleep}
require! 'csv-parse': parse
require! 'prelude-ls': {unique, map, split}

get-csv = (string, delimiter, callback) ->
    # http://csv.adaltas.com/parse/examples/
    err, res <- parse string, {comment: '#', delimiter: delimiter} #\t
    callback err, res

Ractive.components['csv-importer'] = Ractive.extend do
    isolated: yes
    template: RACTIVE_PREPARSE('index.pug')
    onrender: ->
        ack-button = @find-component 'ack-button'
        delimiter = @get \delimiter
        try
            columns = @get \columns
                |> split ','
                |> map (.trim!)

            for column in columns
                throw {message: "duplicate column name"} if columns.length isnt unique columns .length
                throw {message: "column name can not be null"} if column in [null, '', undefined]
        catch
            <~ sleep 0
            console.error "csv import:", e.message
            ack-button.error e.message
            return

        @on do
            get-content: (ctx) ->
                csv = @get \csv
                err, res <~ get-csv csv, delimiter
                if err
                    return ctx.component.error "csv file isnt proper !!!"

                if res.length is 0
                    return ctx.component.error "Empty data"

                column-list = []
                for imported in res
                    a = {}
                    """
                    if columns.length isnt imported.length
                        return ctx.component.error "columns can not match with given csv file's columns !!!"
                    """
                    for index, cell of imported
                        if columns[index]
                            a[that] = cell

                    column-list.push a

                @fire \import, {button: ctx.component}, column-list


    data: ->
        csv: ""
        columns:""
