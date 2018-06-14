Create a `show` function to transform a single document on the fly:

```ls
shows:
    detail: (doc, req) ->
        # {{db}}/_design/{{designDocument}}/_show/{{showsKey}}/{{documentId}}
        #
        # Example:
        #
        #     https://example.com/_users/_design/_auth/_show/detail/org.couchdb.user:foo
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
```

Go to https://example.com/_users/_design/_auth/_show/detail/org.couchdb.user:foo
to see the transformed document.
