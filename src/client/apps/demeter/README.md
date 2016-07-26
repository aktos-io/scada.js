# Design Documents

views:
    get-orders:
        map: (doc) ->
            if doc.type is \order
                emit doc._id, 1


lists:
    my-orders: (head, req) ->
        # see : https://demeter.cloudant.com/cicimeze/_design/orders/_list/myOrders/getOrders?include_docs=true
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
                    html += "<li>#{i.type} : #{i.amount}</li>"
                html += "    </ol>"
                html += "</li>"

            html += """
                        </ul>
                    </body>
                </html>
                """
