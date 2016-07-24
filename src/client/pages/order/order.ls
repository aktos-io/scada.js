require! components
require! 'aea': {PouchDB, sleep, unix-to-readable, merge}
require! 'prelude-ls': {sum, split, sort-by, flatten, group-by, reverse }

db = new PouchDB 'https://demeter.cloudant.com/cicimeze', {+skip-setup}
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
                # Generate output for production list
                @set \output, docs
                curr-doc = @get \curr
                #console.log "curr doc is: ", curr-doc

                function generate-view client-list
                    #console.log "client list is (after): ", client-list
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

                    #console.log "generated view: ", view
                    callback view

                client-list = @get \x
                #console.log "client list seems: ", client-list
                if typeof! client-list is \Array
                    #console.log "client list is here: ", client-list
                    generate-view client-list
                else
                    @observe-once \x, (val) ->
                        #console.log "client list observed: ", val
                        generate-view val

            handlers:
                send-to-production: (orders-to-produce) ->
                    db = @get \db
                    tabledata = @get \tabledata
                    __ = @

                    order-list = if orders-to-produce is \all-visible
                        console.log "WARNING: sending all visible orders to production..."
                        [..id for @get \tableview]
                    else if orders-to-produce not in [null, void]
                        console.log "sending some orders: ", flatten Array orders-to-produce
                        flatten Array orders-to-produce
                    else
                        console.log "nothing will be sent to production... : ", orders-to-produce
                        []



                    orders-edited = [.. `merge` {state: \doing} for tabledata when .._id in order-list]
                    material-usage = get-material-usage get-production-items [.. for tabledata when .._id in order-list]
                    console.log "these documents will be sent to production: ", order-list
                    console.log "following materials will be used for these orders: ", material-usage
                    updated-materials = [..current-status `merge` {curr-amount: ..current-status.curr-amount - ..usage} for material-usage]
                    console.log "updated material list is: ", updated-materials

                    err, res <- db.bulk-docs (orders-edited ++ updated-materials), {+all_or_nothing}
                    if not err
                        console.log "All intended orders are sent to production: response: ", res
                        tabledata `merge` order-list
                        curr = __.get \curr
                        curr `merge` [.. for order-list when .._id is curr._id].0
                        __.set \curr, curr
                    else
                        console.log "ERR on change state: ", err

                material-usage: ->
                    # TEST
                    tableview = [td for td in (@get \tabledata) for w in (@get \tableview) when td._id is w.id]

                    p-list = get-production-items tableview
                    console.log "ORDERS TABLE: production list (current all): ", p-list

                    materials = get-material-usage p-list
                    console.log "ORDERS TABLE: materials needed: ", materials

                get-curr-usage: ->
                    curr = @get \curr
                    console.log "GET_CURR_USAGE: current order: ", curr
                    get-material-usage get-production-items curr


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
                all: (docs, param) ->
                    sort-by (.product-name.to-lower-case!), docs


            after-filter: (docs, on-complete) ->
                    on-complete [{id: .._id, cols: [..product-name]} for docs]

        #RAWMATERIALS
        raw-materials:
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

        # CUSTOMERS
        customers-settings:
            default:
                type: \customer
                name: null
                key: null
            col-names: "Müşteri adı"
            filters:
                all: (docs, param) ->
                    sort-by (.name.to-lower-case!), docs

            after-filter: (docs, callback) ->
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
                        production-list = @get \production-list
                        #console.log "MATERIAL_USAGE_TABLE: production-list: ", production-list
                        x = get-material-usage get-production-items production-list
                        #console.log "MATERIAL_USAGE TABLE: ", x
                        [{id: ..id, cols: [..name, "#{..usage} kg"]} for x]

        menu-public:
            * title: "Ana Sayfa"
              url: '#/'
            ...



feed = null
ractive.on do
    'login.success': ->
        console.log "running after logged in..."
        do function on-change
            console.log "running function on-change!"

            err, res <- db.query 'customers/getCustomers', {+include_docs}
            if err
                console.log "ERROR customer list: ", err
            else
                #console.log "customer list updated: ", res
                ractive.set \customersList, [{name: ..doc.name, id: ..doc.key} for res.rows]

        feed?.cancel!
        feed := local?.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                on-change!

        menu-public = ractive.get \menuPublic
        ractive.set \menu, menu-public ++ menu-private =
            * title: "Siparişler"
              icon: "fa fa-bar-chart-o"
              url: '#/orders'
            * title: "Stok Girişi"
              url: '#/stock'
            * title: "Ayarlar"
              icon:"fa fa-th-large"
              sub-menu:
                * title: "Müşteri Tanımla"
                  url: '#/definitions/client'
                * title: "Reçete Tanımla"
                  url: '#/definitions/recipe'
                * title: "Hammadde Tanımla"
                  url: '#/definitions/raw-material'
            * title: "Destek"
              url: '#/help'

    'login.logout': ->
        ractive.set \menu, ractive.get \menuPublic


function get-production-items docs
    /*
        Input:  an array of `type: \order` documents (or one order doc)
        returns: total production list
    */
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
