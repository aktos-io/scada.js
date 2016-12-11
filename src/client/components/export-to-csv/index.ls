require! 'prelude-ls': {
    map
}

base64 = (s) -> window.btoa unescape encodeURIComponent s

component-name = "export-to-file"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        _link = $ @find \.download-link
        @on do
            __prepare-download: ->
                __ = @
                err, res <- @fire \prepareDownload
                #a = @find "download-link"

                # generate file content
                content = ''
                col-names = __.get \col-names
                if col-names
                    content += "#{col-names}\n"

                for row in res.content
                    col-str = row.join ','
                    content += col-str + '\r\n'

                # create content
                filename = res.filename or "file-#{Date.now!}.csv"
                filecontent = "data:attachment/csv;base64,77u/#{base64 content}"

                # start download
                a = document.createElement \a
                document.body.append-child a
                a.download = filename
                a.href = filecontent
                a.click!

    data: ->
        data: []
        filename: null
        'col-names': null
        filecontent: null
        download-link-ready: no
