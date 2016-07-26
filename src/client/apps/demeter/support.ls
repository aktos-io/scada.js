# SUPPORT
export support:
    settings:
        default:
            type: \issue
            subject: 'Başlık...'
            date: null
            body: null
            reply-to: null

        col-names: "Konu"

        filters:
            all: (docs) -> docs

        after-filter: (docs, callback) ->
            callback [{id: .._id, cols: [..subject]} for docs]

        handlers:
            submit: ->
                console.log "HANDLER: ", ractive
