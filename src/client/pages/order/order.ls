require! components
require! 'aea': {PouchDB, sleep}
require! 'prelude-ls': {sum, split}

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
        orders-col-names: "Müşteri Adı, Teslim Tarihi, Toplam (kg)"
        orders-filters:
            all: (docs, param) ->
                [[..client, ..due-date] for docs]
                #[[i.doc.client, i.doc.due-date, sum [(split ' ', ..amount .0 |> parse-int) for i.doc.entries]] for i in docs]
            cheese: (docs, param) ->
                [[..client, ..due-date] for docs when \Cheesecake in [i.product for i in ..entries]]

            who: (docs, param) ->
                x = [[..client, .._id, 1] for docs]

            todays-orders: (docs, param) ->
                now = Date.now!
                tomorrow = now + 1day * 24hours_per_day * 3600seconds_per_hour * 1000ms_per_second

                console.log "calculated now: ", now
                author = (doc) -> (split '-', doc._id).0

                orders = [[..client, author .., \selam ] for docs when now < ..due-date < tomorrow]
                console.log "Siparişler: found #{orders.length} orders. "
                orders


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
                console.log "Running custom filter (receipts)", docs
                [[..product-name] for docs]

        # CUSTOMERS
        customers-default:
            type: \customer
        customers-col-names: "Müşteri adı"
        customers-filters:
            all: (docs, param) ->
                console.log "Running custom filter (customers)", docs
                [[..name] for docs]

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
                ractive.set \customersList, [{name: ..doc.name, id: ..doc.name} for res.rows]

        feed?.cancel!
        feed := local?.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                on-change!
