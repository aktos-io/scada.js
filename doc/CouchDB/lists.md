## List example

List functions are used to transform a view function result on the fly. Create
a design document with the following content:

```ls
views:
    get-orders:
        map: (doc) ->
            if doc.type is \order
                emit doc._id, 1

lists:
    my-orders: (head, req) ->
        # see : https://example.com/mydb/_design/orders/_list/myOrders/getOrders?include_docs=true
        provides \html, ->
            html = """
                <html>
                    <body>
                        <ul>
                """
            while row = get-row!
                html += "<li>#{row.key} : #{row.doc.client}"
                html += "    <ol>"
                for i in row.doc.entries
                    html += "<li>#{i.type}</li>"
                html += "    </ol>"
                html += "</li>"

            html += """
                        </ul>
                    </body>
                </html>
                """
```

...and go to https://example.com/mydb/_design/orders/_list/myOrders/getOrders?include_docs=true
in order to get the transformed result of `myOrders/getOrders` view.
