# Event Signature:

handler: (ctx, file, next) -> ...

Where:
ctx.heartbeat(milliseconds): postpone the timeout error
file: The uploaded file. Properties (eg. for foo.svg file)

    name: "foo.svg"
    ext: "svg"
    file_type: "text"
    type: "image/svg+xml"
    raw: "...content of file..."
    blob: `File` object
    previewUrl: "blob:http://localhost:4001/660893d3-2bba-417f-bb99-226d1b8f8559"

# Simple Usage

Possible types: csv, text

```pug
file-button.icon(
    on-read="importClients"
    type="csv"
    columns="netsis,id,province,district,respective_person"
    )
    icon.upload Clients
```

# Example 2

Text file reading example:

```pug
file-button(
    on-read="restoreDesignDocs"
    type="text"
    ) Upload!
```

```ls
restoreDesignDocs: (ctx, file, next) ->
    docs = JSON.parse file.raw
    for ddoc in docs
        delete ddoc._rev
        console.log "Design Doc: #{ddoc._id}"
    err, res <~ db.put docs
    next err
```
