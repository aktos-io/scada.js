require! 'prelude-ls': {sum, split, sort-by, flatten, group-by, reverse }
require! 'aea': {sleep, merge}

export function get-production-items docs
    /*
        Input:  an array of `type: \order` documents (or one order doc)
        returns: total production list
    */
    return [] if docs in [null, void]
    #console.log "GETTING PRODUCTION ITEMS... "

    docs = flatten Array docs
    production-list = flatten [flatten([{id: .._id} `merge ` i for i in ..entries]) for docs]
    #console.log "PRODUCTION LIST: ", production-list
    # order-id, product-name, amount
    production-items = group-by (.product), production-list
    production-total = [{
        product-name: name
        total-amount: sum [parse-float ..amount for entries]
        related-orders: [..id for entries]
        } for name, entries of production-items]
    #console.log "Production list as groups:", production-items
    #console.log "Production list as documents", production-total
    #console.log "GOT PRODUCTION ITEMS... "
    production-total



export function get-material-usage production-list, recipes, stock-materials
    /*
        Input: An array of production items and their amounts
        Returns: Needed raw material for producing these items

        id      : material document id
        name    : material name
        key     : material key name
        usage   : material usage
    */

    return [] if production-list is void

    #console.log "GET_MATERIAL_USAGE: recipes: ", recipes
    #console.log "GET_MATERIAL_USAGE: production-list: ", production-list
    #console.log "GET_MATERIAL_USAGE: stock material list: ", stock-materials

    # raw material list: no grouping
    material-usage-raw = [{
        name: production.product-name
        materials: [{material: ..material, amount: parse-float(..amount) * parse-float production.total-amount} for recipe.contents]
    } for production in production-list for recipe in recipes
    when production.product-name is recipe.product-name]
    #console.log "GET_MATERIAL_USAGE: material usage RAW: ", material-usage-raw

    # raw material list: group by material
    material-list = group-by (.material), flatten [..materials for material-usage-raw]
    #console.log "GET_MATERIAL_USAGE: material usage: ", material-list

    # format the material list
    x = [{
        id: stock._id
        name: material-name
        key: stock.key
        usage: sum [parse-float ..amount for usage]
        current-status: stock
    } for material-name, usage of material-list for stock in stock-materials
    when stock.name.to-lower-case! is material-name.to-lower-case!]
    #console.log "GET_MATERIAL_USAGE: material usage summary: ", x
    x
