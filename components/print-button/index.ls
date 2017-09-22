require! 'aea':{sleep}
require! 'actors': {RactiveActor}


Ractive.components['print-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        @actor = new RactiveActor this, name: 'print button'

        @on do
            _preparePrint: (ctx) ->
                const c = ctx.getParent yes
                c.refire = yes
                c.button = ctx.component

                # important: open printWindow before doing anything async.
                printWindow = window.open('', '', 'scrollbars=yes, resizable=yes, width=800, height=500')
                unless printWindow
                    return c.button.error do
                        title: \Error
                        icon: "warning sign"
                        message: 'Your browser does not let me open a window!'
                printWindow.document.writeln """
                    <h2>Preparing content...</h2>
                    """
                printWindow.document.close!

                res <~ @fire \print, c

                if res.html
                    doc = that
                else
                    if res.body
                        body = that
                    else
                        r = new Ractive do
                            template: res.template
                            data: res.data

                        body = r.toHTML!

                res.title = that if @get \title

                doc = """
                    <html  moznomarginboxes mozdisallowselectionprint>
                        <head>
                            <script src="js/vendor.js"></script>
                            <link rel="stylesheet" href="css/vendor.css">
                            <title>#{res.title or res.data.title}</title>
                            <style>
                                /* in order to disable page header and footer */
                                @page {
                                    margin: 0;
                                }
                                /* Re-create A4 sized div */
                                \#page-container {
                                    padding: 15mm;
                                    width: 210mm;
                                    height: 297mm;
                                    border: 1px dashed red; /* for debugging purposes */
                                }
                                /* prevent last empty page */
                                @media print {
                                    html, body {
                                        border: 1px solid white;
                                        page-break-after: avoid;
                                        page-break-before: avoid;
                                    }
                                }

                                /* in order to be able to use absolute css in
                                our print pages' templates */
                                \#page-inner {
                                    position: relative;
                                }


                                .no-print {
                                    display: none;
                                }
                                #{res.style} /* additional styles */
                            </style>
                        </head>
                        <body>
                            <div id="page-container">
                                <div id="page-inner">
                                    #{body}
                                </div>
                            </div>
                            <!-- <script>window.print(); window.close()</script> -->
                        </body>
                    </html>
                    """
                @actor.send 'app.log.info', do
                    title: "Print window"
                    message: "Close the print window before continue"

                printWindow.document.writeln doc
                printWindow.document.close!
