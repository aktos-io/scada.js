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
        x: -1

        # ORDERS
        orders-default:
            type: \order
            client: "Müşteri...."
            due-date: "1.2.3.4"
            order-date: "22.2.2.2."
            entries:
                * product: "Rus salata"
                  amount: "2kg"
                ...
        orders-col-names: "Müşteri Adı, Sipariş Tarihi, Teslim Tarihi"
        orders-filters:
            all: (docs, param, __) ->
                client-list = __.x
                console.log "client list is: ", client-list
                conv = unix-to-readable
                known = [{id: doc._id, cols: [client.name, doc.order-date, doc.due-date]} for doc in docs for client in client-list when client.id is doc.client]

                # sort by date
                x = reverse sort-by (.cols.2), known
                [{id: ..id, cols: [..cols.0, conv(..cols.1), conv(..cols.2)]} for x]

            cheese: (docs, param) ->
                    [{id: .._id, cols: [..client, ..due-date]} for docs when \Cheesecake in [i.product for i in ..entries]]

            who: (docs, param) ->
                x = [{id: .._id, cols: [..client, .._id, 1]} for docs]

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
                    x = [{id: \aa, cols: [product, (sum [parse-int ..amount for entries])]} for product, entries of y]
                    console.log "Production list as table", y

                    #x = [{id: ..id, cols: [..id, ..product, ..amount]} for production-list]
                    __.set \output, x
                catch
                    console.log "ORDER_TABLE: error: ", e
                sort-by (.cols.2), orders

            refresh-production: (docs, param) ->


                local.query my-map, {key: \next_days, +include_docs}, (err, res) ->
                    try
                        throw err if err
                        console.log "Local query: ", res
                    catch
                        console.log "err..", err



        # RECEIPTS
        receipts-default:
            type: \receipt
            product-name: "Ürün Adı"
            contents:
                * material: "Ham madde..."
                  amount: "x kg"
                ...
        receipts-col-names: "Ürün adı"
        receipts-filters:
            all: (docs, param) ->
                #console.log "Running custom filter (receipts)", docs
                [{id: .._id, cols: [..product-name]} for docs]

        # CUSTOMERS
        customers-default:
            type: \customer
        customers-col-names: "Müşteri adı"
        customers-filters:
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
                        docs

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
