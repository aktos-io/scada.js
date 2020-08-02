require! 'aea':{sleep}
require! 'actors': {RactiveActor}

Ractive.components['print-button'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        @actor = new RactiveActor this, name: 'print button'

        @on do
            _preparePrint: (ctx) ->
                const c = ctx.getParent yes
                c.refire = yes
                c.button = ctx.component
                c.proxy = ctx  # FIXME: This is a workaround to make `ctx.get('my-attribute')` work

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

                try
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
                catch
                    debugger

                print-css = '''
                    /* in order to disable page header and footer */
                    @page {
                        margin: 0;
                    }

                    /* Re-create A4 sized div */
                    #page-container {
                        border: 1px dashed red; /* for debugging purposes */
                        padding: 1cm;
                        width: 210mm;
                        height: 297mm;
                    }

                    /* to be able to use absolute css */
                    #page-inner {
                        position: relative;
                        height: 100%;
                        /*border: 1px dotted green;*/
                        display:flex;
                        flex-flow: column nowrap;
                    }

                    .fit-image {
                      flex: 1;
                      /*border: 1px solid yellow;*/
                      background-size: contain !important;
                      background-repeat: no-repeat;
                      background-size: auto 100%;
                      background-position: center center;
                    }



                    /* Defining all page breaks */
                    a {
                        page-break-inside:avoid
                    }
                    blockquote {
                        page-break-inside: avoid;
                    }
                    h1, h2, h3, h4, h5, h6 { page-break-after:avoid;
                         page-break-inside:avoid }
                    img { page-break-inside:avoid;
                         page-break-after:avoid; }
                    table, pre { page-break-inside:avoid }
                    ul, ol, dl  { page-break-before:avoid }

                '''

                doc = """
                    <html  moznomarginboxes mozdisallowselectionprint>
                        <head>
                            <link rel="stylesheet" href="css/vendor.css">
                            <script src="js/vendor.js"></script>
                            <link rel="stylesheet" href="css/vendor2.css">
                            <script src="js/vendor2.js"></script>
                            <title>#{res.title or res.data.title}</title>
                            <style>
                                @media all{
                                    #{print-css}
                                    #{res.style} /* additional styles */
                                }
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

                printWindow.document.writeln doc
                printWindow.document.close!
