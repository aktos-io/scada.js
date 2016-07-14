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
            all: (rows, param) ->
                console.log "orders My custom all filter data: ", rows
                [[..doc.client] for rows]
                #[[i.doc.client, i.doc.due-date, sum [(split ' ', ..amount .0 |> parse-int) for i.doc.entries]] for i in rows]
            aaa: (rows, param) ->
                console.log "Cheesecake filter running...", rows
                [[..doc._id] for rows]
                #[.. for rows when 'Cheesecake' in [i.product-name for i ..doc.entries]]
            who: (rows, param) ->
                x = [[..doc.client, ..doc._id, 1] for rows]
                console.log "who filter: ", x 
                x

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
            all: (rows, param) ->
                console.log "Running custom filter (receipts)"
                [[i.doc.product-name] for i in rows]

        # CUSTOMERS
        customers-default:
            type: \customer
        customers-col-names: "Müşteri adı"
        customers-filters:
            all: (rows, param) ->
                console.log "Running custom filter (customers)"
                [[i.doc.name] for i in rows]

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
