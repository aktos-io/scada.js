require! 'prelude-ls': {
    map
}

require! 'aea':{gen-entry-id, sleep}

/*
response =
    content: content of print area
    title: title (if exists)
*/

Ractive.components['print-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        id = "print-#{gen-entry-id!}"
        @set \data-source, id
        @on do
            __prepare-print: ->
                __ = @
                source-node = $ "[data-source=#{id}]"
                err, res <- @fire \print, source-node.html!, @get('value')
                return console.error "Error while printing: ", err.message if err

                printWindow = window.open('', '', 'scrollbars=yes, resizable=yes, width=800, height=500')
                unless printWindow
                    return alert 'Your browser does not let me open a window!'

                # TODO: add stylesheets in place
                #a = document.styleSheets
                #debugger

                doc = if res.html
                    res.html
                else
                    """
                    <html  moznomarginboxes mozdisallowselectionprint>
                        <head>
                            <link rel="stylesheet" href="css/vendor.css">
                            <style>
                                .no-print {
                                    display: none;
                                }

                                #{res.style}
                            </style>
                        </head>
                        <body>
                            #{res.body}
                        </body>
                        <script>window.print(); window.close()</script>
                    </html>
                    """
                printWindow.document.writeln doc
                printWindow.document.close!
    data: ->
        'source-class': null
        value: null
