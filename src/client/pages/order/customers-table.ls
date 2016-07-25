require! 'prelude-ls': {sort-by}

# CUSTOMERS
export customers:
    settings:
        default:
            type: \customer
            name: null
            key: null
        col-names: "Müşteri adı"
        filters:
            all: (docs, param) ->
                x = sort-by (.name), docs

        after-filter: (docs, callback) ->
            callback [{id: .._id, cols: [..name]} for docs]

        handlers:
            set-client-id: (key) ->
                console.log "setting current key to: #{key}", @
                try @set "curr.key", "client-id-#{key.to-lower-case!}"
                \ok
