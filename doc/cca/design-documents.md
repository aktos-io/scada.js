views:
    get-admins:
        map: (doc) ->
            if 'cici' in doc.roles
                emit doc._id, 1

            # utility functions
            function in$ x, xs
                i = -1; l = xs.length .>>>. 0
                while ++i < l
                    if x is xs[i] then return true
                return false

validate_doc_update: (new-doc, old-doc, user-ctx, sec-obj) ->
    # utility functions
    function in$ x, xs
        i = -1; l = xs.length .>>>. 0
        while ++i < l
            if x is xs[i] then return true
        return false

shows:
    detail: (doc, req) ->
        # {{db}}/_design/{{designDocument}}/_show/{{showsKey}}/{{documentId}}
        #
        # For example:
        #
        #     https://demeter.cloudant.com/_users/_design/_auth/_show/detail/org.couchdb.user:mahmut1
        #
        headers:
            "Content-Type": "text/html"

        body: """
            <html>
                <head>
                </head>
                <body>
                    <h1>#{doc.name}</h1>
                </body>
            </html>
            """
