require! 'prelude-ls': {sum, split, sort-by, flatten, group-by, reverse }

# RECIPES
export recipes:
    settings:
        default:
            type: \receipt
            product-name: "Ürün Adı"
            contents:
                * material: "Ham madde..."
                  amount: "x kg"
                ...

        col-names: "Ürün adı"
        filters:
            all: (docs, param) ->
                sort-by (.product-name.to-lower-case!), docs


        after-filter: (docs, on-complete) ->
                on-complete [{id: .._id, cols: [..product-name]} for docs]
