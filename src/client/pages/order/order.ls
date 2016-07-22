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
                    curr = @get \curr
                    db = @get \db

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

        # CUSTOMERS
        customers-settings:
            default:
                type: \customer
                name: null
                key: null
            col-names: "Müşteri adı"
            filters:
                all: (docs, param) ->
                    console.log "running customers 'all' filter...", docs
                    docs

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
                        production-list = flatten [flatten([{id: .._id} `merge ` i for i in ..entries]) for docs]
                        console.log "PRODUCTION LIST: ", production-list
                        # order-id, product-name, amount
                        production-items = group-by (.product), production-list
                        production-total = [{
                            product-name: name
                            total-amount: sum [parse-float ..amount for entries]
                            related-orders: [..id for entries]
                            } for name, entries of production-items]
                        console.log "Production list as groups:", production-items
                        console.log "Production list as documents", production-total
                        @set \output, production-total

                        i = 0
                        seq-num = (x) -> i++
                        x = reverse sort-by (.total-amount), production-total
                        [{id: seq-num(..), cols:[..product-name, "#{..total-amount} kg"]} for x]

        # MATERIAL USAGE
        material-usage:
            settings:
                cols: "Hammadde Adı, Miktar"
                filters:
                    all: (docs) ->
                        __ = @

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
