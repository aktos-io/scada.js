require! 'prelude-ls': {
    map
}
require! 'aea': {copyToClipboard}
base64 = (s) -> window.btoa unescape encodeURIComponent s

Ractive.components["export-to-csv"] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        _link = $ @find \.download-link
        @on do
            __prepare-download: ->
                __ = @
                __.set \state, \doing
                err, res <- @fire \prepareDownload
                #a = @find "download-link"

                # generate file content
                col-names = try
                    x = __.get \col-names
                    throw unless x
                    x
                catch
                    try
                        throw unless res.col-names
                        if typeof res.col-names is \string
                            res.col-names
                        else
                            res.col-names.join ','
                    catch
                        ''

                # convert array of arrays to csv
                content = ""
                #content += "\"sep=,\"\r\n" # Excel default separator workaround
                if col-names isnt ""
                    content = "#{col-names}\r\n"
                for row in res.content
                    for j, col of row
                        inner-value = col?.to-string!
                        result = inner-value.replace /"/g, '""'
                        if result.search(/("|,|\n)/g) >= 0
                            result = "\"#{result}\""
                        content += ',' if j > 0
                        content += result
                    content += '\n'


                # copy to clipboard or dowload as csv
                if __.get \clipboard
                    copyToClipboard content
                    console.log "copied to clipboard???"
                else
                    # create content
                    filename = res.filename or "file-#{Date.now!}.csv"
                    filecontent = "data:attachment/csv;base64,77u/#{base64 content}"

                    # start download
                    a = document.createElement \a
                    document.body.append-child a
                    a.download = filename
                    a.href = filecontent
                    a.click!
                __.set \state, \done...

    data: ->
        data: []
        filename: null
        'col-names': null
        filecontent: null
        download-link-ready: no
        state: 'normal'
