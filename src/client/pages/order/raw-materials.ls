require! 'prelude-ls': {sort-by}

#RAWMATERIALS
export raw-materials:
    settings:
        default:
            type: 'raw-material'
            name: ''
        col-names:"Hammadde Adı, Kritik Miktar, Mevcut Miktar"
        filters:
            all: (docs, param) ->
                sort-by (.name.to-lower-case!), docs

        after-filter: (docs, callback) ->
            #console.log "Raw Material has documents: ", docs
            callback [{id: .._id, cols: [..name, ..critical-amount, ..curr-amount]} for docs]
