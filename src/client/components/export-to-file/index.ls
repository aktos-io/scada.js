component-name = "export-to-file"
Ractive.components[component-name] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.jade')
    isolated: yes
    oninit: ->
        @on do
            prepare-download: ->
                #a = @find "download-link"

                # generate file content
                content = [(@get \col-names)] ++ [..cols.join ',' for (@get \tabledata)]
                @set \fileContent, content.join "%0A"

                # set filename
                filename = (@get \filename) or "file.csv"
                @set \filename, filename
