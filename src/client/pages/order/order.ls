require! components
require! 'aea': {PouchDB, sleep, unix-to-readable, merge}
require! 'prelude-ls': {sum, split, sort-by, flatten, group-by, reverse }

db = new PouchDB 'https://demeter.cloudant.com/cicimeze', skip-setup: yes
local = new PouchDB \local_db

gen-entry-id = ->
    timestamp = new Date!get-time! .to-string 16
    "#{ractive.get 'login.user.name'}-#{timestamp}"


# Ractive definition
ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        login:
            ok: no
        db: db
        gen-entry-id: gen-entry-id

        # ORDERS
        orders:
            default:
                type: \order
                client: "client-id-aktos"
                due-date: "1.2.3.4"
                order-date: "22.2.2.2."
                entries:
                    * product: "Rus salata"
                      amount: "2kg"
                    ...
            col-names: "Müşteri Adı, Sipariş Tarihi, Teslim Tarihi"
            filters:
                all: (docs, param) ->
                    # sort by date
                    reverse sort-by (.due-date), docs

                todays-orders: (docs, param) ->
                    now = Date.now!
                    tomorrow = now + 1day * 24hours_per_day * 3600seconds_per_hour * 1000ms_per_second

                    console.log "calculated now: ", now
                    [.. for docs when now < ..due-date < tomorrow]

                doing: (docs) ->
                    [.. for docs when ..state is \doing]

                done: (docs) ->
                    [.. for docs when ..state is \done]

            after-filter: (docs, callback) ->
                console.log "running after filter..."

                # Generate output for production list
                @set \output, docs

                function generate-view client-list
                    console.log "client list is (after): ", client-list
                    view = [{
                    id: doc._id
                    cols:
                        client.name
                        unix-to-readable doc.order-date
                        unix-to-readable doc.due-date
                    class: if doc.state is \doing
                        \warning
                    else if doc.state is \aborted
                        \danger
                    else if doc.state is \done
                        \success
                    } for doc in docs for client in client-list
                    when client.id is doc.client]

                    callback view

                client-list = @get \x
                if typeof! client-list is \Array
                    generate-view client-list
                else
                    @observe-once \x, generate-view

            handlers:
                set-production-state: (state) ->
                    __ = @
                    db = @get \db

                    curr = @get \curr
                    curr.state = state
                    console.log "changing production state to: ", state
                    err, res <- db.put curr
                    if not err
                        console.log "CHANGED PRODUCTION STATE!", curr
                        curr._rev = res.rev
                        console.log "Updating current order document rev: ", curr._rev
                        __.set \curr, curr
                    else
                        console.log "ERR on change state: ", err

                send-all-to-production: ->
                    db = @get \db
                    order-list = [..id for @get \tableview]
                    console.log "these documents will be sent to production: ", order-list

                    err, res <- db.bulk-docs [.. `merge` {state: \doing} for (@get \tabledata) when .._id in order-list]
                    if not err
                        console.log "All visible orders sent to production: response: ", res
                    else
                        console.log "ERR on change state: ", err

                material-usage: ->
                    tableview = [td for td in (@get \tabledata) for w in (@get \tableview) when td._id is w.id]

                    p-list = get-production-items tableview
                    console.log "ORDERS TABLE: production list (current all): ", p-list

                    materials = get-material-usage p-list
                    console.log "ORDERS TABLE: materials needed: ", materials





        # RECIPES
        recipes:
            default:
                type: \receipt
                product-name: "Ürün Adı"
                contents:
                    * material: "Ham madde..."
                      amount: "x kg"
                    ...

            col-names: "Ürün adı"
            filters:
                all: (docs, param) -> docs

            after-filter: (docs, on-complete) ->
                    on-complete [{id: .._id, cols: [..product-name]} for docs]

        #RAWMATERIALS
        raw-materials:
            settings:
                default:
                    type: 'raw-material'
                col-names:"Hammadde Adı, Kritik Miktar"
                filters:
                    all: (docs, param) -> docs

                after-filter: (docs, callback) ->
                    #console.log "Raw Material has documents: ", docs
                    callback [{id: .._id, cols: [..name, ..critical-amount]} for docs]

        # CUSTOMERS
        customers-settings:
            default:
                type: \customer
                name: null
                key: null
            col-names: "Müşteri adı"
            filters:
                all: (docs, param) -> docs

            after-filter: (docs, callback) ->
                console.log "running after-filter for customers"
                callback [{id: .._id, cols: [..name]} for docs]

            handlers:
                set-client-id: (key) ->
                    console.log "setting current key to: #{key}", @
                    try @set "curr.key", "client-id-#{key.to-lower-case!}"
                    \ok

        # PRODUCTION
        production:
            settings:
                cols: "Ürün Adı, Miktar"
                filters:
                    all: (docs) ->
                        x = get-production-items docs
                        [{id: ..product-name, cols:[..product-name, "#{..total-amount} kg"]} for x]

        # MATERIAL USAGE
        material-usage:
            settings:
                cols: "Hammadde Adı, Miktar"
                filters:
                    all: (docs) ->
                        x = get-material-usage @get \production-list
                        console.log "MATERIAL_USAGE TABLE: ", x
                        [{id: ..id, cols: [..name, "#{..usage} kg"]} for x]

        menu:
            * title: "Ayarlar"
              icon:"fa fa-th-large"
              sub-menu:
                * title: "Müşteri Tanımla"
                  url: '#/definitions/client'
                * title: "Reçete Tanımla"
                  url: '#/definitions/recipe'
                * title: "Hammadde Tanımla"
                  url: '#/definitions/raw-material'
            * title: "Siparişler"
              icon: "fa fa-bar-chart-o"
              sub-menu:
                * title: "Sipariş Listesi"
                  url: '#/orders'
                ...



feed = null
ractive.on do
    after-logged-in: ->
        do function on-change
            console.log "running function on-change!"

            err, res <- db.query 'customers/getCustomers', {+include_docs}
            if err
                console.log "ERROR customer list: ", err
            else
                console.log "customer list updated: ", res
                ractive.set \customersList, [{name: ..doc.name, id: ..doc.key} for res.rows]

        feed?.cancel!
        feed := local?.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                on-change!

function get-production-items docs
    /*
        Input:  an array of `type: \order` documents (or one order doc)
        returns: total production list
    */
    console.log "GETTING PRODUCTION ITEMS... "
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
    console.log "GOT PRODUCTION ITEMS... "
    production-total



function get-material-usage production-list
    /*
        Input: An array of production items and their amounts
        Returns: Needed raw material for producing these items

        id      : material document id
        name    : material name
        key     : material key name
        usage   : material usage
    */
    recipes = ractive.get \materialUsage.recipes
    stock-materials = ractive.get \rawMaterials.tabledata

    #console.log "GET_MATERIAL_USAGE: recipes: ", recipes
    console.log "GET_MATERIAL_USAGE: production-list: ", production-list
    #console.log "GET_MATERIAL_USAGE: stock material list: ", stock-materials

    material-usage-raw = [{
        name: production.product-name
        materials: [{material: ..material, amount: parse-float(..amount) * parse-float production.total-amount} for recipe.contents]
    } for production in production-list for recipe in recipes
    when production.product-name is recipe.product-name]
    console.log "GET_MATERIAL_USAGE: material usage RAW: ", material-usage-raw

    material-list = group-by (.material), flatten [..materials for material-usage-raw]
    console.log "GET_MATERIAL_USAGE: material usage: ", material-list

    x = [{
        id: stock._id
        name: material-name
        key: stock.key
        usage: sum [parse-float ..amount for usage]
    } for material-name, usage of material-list for stock in stock-materials
    when stock.name.to-lower-case! is material-name.to-lower-case!]

    console.log "GET_MATERIAL_USAGE: material usage summary: ", x
    x
