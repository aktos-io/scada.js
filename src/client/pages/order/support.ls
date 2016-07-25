# SUPPORT
export support:
    settings:
        default:
            type: \issue
            subject: 'Başlık...'
            date: null
            entries:
                * author: ''
                  body: ''
                ...

        col-names: "Konu"
        filters:
            all: (docs, param) ->
                docs

        after-filter: (docs, callback) ->
            callback [{id: .._id, cols: [..subject]} for docs]
