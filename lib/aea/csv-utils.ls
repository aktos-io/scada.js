require! 'csv-parse/lib/es5': parse
require! 'prelude-ls': {unique, map, split, empty}

get-csv = (string, delimiter, callback) ->
    # http://csv.adaltas.com/parse/examples/
    err, res <- parse string, {comment: '#', delimiter: delimiter} #\t
    callback err, res


export parse-csv = (content, opts={}, callback) ->
    if typeof! opts is \Function =>
        callback = opts
        opts = {}

    delimiter = opts.delimiter or ','
    columns = if opts.columns
        that
        |> split ','
        |> map (.trim!)
    else
        []

    # check columns
    if columns.length isnt unique columns .length
        return callback err={message: "duplicate column name"}
    if empty columns
        return callback err={message: "No column names provided!"}
    for column in columns
        if column in [null, '', undefined]
            return callback err={message: "column name can not be null"}

    err, res <~ get-csv content, delimiter
    if err => return callback err={message: "csv file isnt proper!", error: err}
    if res.length is 0 => return callback err={message: "Empty data"}

    rows = []
    for imported in res
        a = {}
        """
        if columns.length isnt imported.length
            return ctx.component.error "columns can not match with given csv file's columns !!!"
        """
        for index, cell of imported
            if columns[index]
                a[that] = cell

        rows.push a

    return callback err=null, {rows, columns}
