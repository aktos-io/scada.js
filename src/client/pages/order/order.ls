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
                all: (docs, param, __) ->
                    client-list = __.x
                    console.log "client list is: ", client-list
                    conv = unix-to-readable
                    known = [{id: doc._id, cols: [client.name, doc.order-date, doc.due-date]
                    } for doc in docs for client in client-list
                    when client.id is doc.client]

                    # sort by date
                    x = reverse sort-by (.cols.2), known
                    [{id: ..id, cols: [..cols.0, conv(..cols.1), conv(..cols.2)]} for x]

                todays-orders: (docs, param, __this) ->
                    __ = __this.instance
                    now = Date.now!
                    tomorrow = now + 1day * 24hours_per_day * 3600seconds_per_hour * 1000ms_per_second

                    console.log "calculated now: ", now
                    author = (doc) -> (split '-', doc._id).0

                    filtered-docs = [.. for docs when now < ..due-date < tomorrow]
                    orders = [{id: .._id, cols: [..client, author .., \selam ]} for filtered-docs]
                    console.log "Siparişler: found #{orders.length} orders. "

                    console.log "FILTERED DOCS: ", filtered-docs
                    try
                        production-list = flatten [flatten([{id: .._id} `merge ` i for i in ..entries]) for filtered-docs]
                        console.log "PRODUCTION LIST: ", production-list

                        # order-id, product-name, amount
                        y = group-by (.product), production-list
                        x = [{
                            product-name: product
                            total-amount: sum [parse-float ..amount for entries]
                            related-orders: [..id for entries]
                            } for product, entries of y]
                        console.log "Production list as groups:", y
                        console.log "Production list as documents", x

                        #x = [{id: ..id, cols: [..id, ..product, ..amount]} for production-list]
                        __.set \output, x
                    catch
                        console.log "ORDER_TABLE: error: ", e
                    sort-by (.cols.2), orders

                doing: (docs, param, __this) ->
                    [{id: .._id, cols: [..client, ..order-date, ..due-date]
                    } for docs when ..state is \doing]

            handlers:
                send-to-production: (params) ->
                    [curr, db] = params
                    curr.state = \doing
                    err, res <- db.put curr
                    if not err
                        console.log "SENT TO PRODUCTION!", curr
                    else
                        console.log "Not sent to production: ", err



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
                    [{id: .._id, cols: [..product-name]} for docs]

        # CUSTOMERS
        customers:
            default:
                type: \customer
            col-names: "Müşteri adı"
            filters:
                all: (docs, param) ->
                    console.log "running customers 'all' filter..."
                    [{id: .._id, cols: [..name]} for docs]


                set-client-id: (key, __) ->
                    console.log "setting current key to: #{key}", __
                    try __.instance.set "curr.key", "client-id-#{key.to-lower-case!}"
                    \ok

        # PRODUCTION
        production:
            settings:
                cols: "Ürün Adı, Miktar"
                filters:
                    all: (docs, param, this_) ->
                        #rows = [{id: ..id, cols: [..name, ..amount]} for docs]
                        i = 0
                        seq-num = (x) -> i++
                        x = reverse sort-by (.total-amount), docs
                        [{id: seq-num(..), cols:[..product-name, "#{..total-amount} kg"]} for x]

        # MATERIAL USAGE
        material-usage:
            settings:
                cols: "Hammadde Adı, Miktar"
                filters:
                    all: (docs, param, this_) ->
                        __ = this_.instance

                        try
                            productions = __.get \production-list
                            recipes = __.get \recipes
                            console.log "MATERIAL_USAGE: recipes: ", recipes
                            console.log "MATERIAL_USAGE: productions: ", productions
                            material-usage-raw = [{
                                name: production.product-name
                                materials: [{material: ..material, amount: parse-float(..amount) * production.total-amount} for recipe.contents]
                            } for production in productions for recipe in recipes
                            when production.product-name is recipe.product-name]

                            console.log "material usage: ", material-usage-raw
                            material-list = group-by (.material), flatten [..materials for material-usage-raw]
                            console.log "material usage all: ", material-list
                            i = 0
                            gen-id = -> i++
                            x = [{id: gen-id!, cols: [material, "#{sum [..amount for usage]} kg"]} for material, usage of material-list]
                            console.log "material usage table: ", x
                            x
                        catch
                            console.log "Material usage error: ", e

        menu:
            * title: "Ayarlar"
              icon:"fa fa-th-large"
              sub-menu:
                * title: "Tüm Tanımlar"
                  url: '#/definitions'
                * title: "Müşteri Tanımla"
                  url: '#/definitions/client'
                * title: "Reçete Tanımla"
                  url: '#/definitions/recipe'
            * title: "Siparişler"
              icon: "fa fa-bar-chart-o"
              sub-menu:
                * title: "Sipariş Listesi"
                  url: '#/orders'
                * title: "Üretim Kalemleri Toplamı"
                  url: '#/orders/production-items'
                * title: "Gereken Hammadde Miktarı"
                  url: '#/orders/raw-material-usage'


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
