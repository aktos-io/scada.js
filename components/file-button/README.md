# Event Signature:

handler: (ctx, file, next) -> ...

Where:
ctx.heartbeat(milliseconds): postpone the timeout error
file: the uploaded file
    file.csv if file is csv type

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
