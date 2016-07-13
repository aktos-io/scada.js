require! components
require! 'aea': {PouchDB}
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
        orders-view-generator: (res) ->
            [[i.doc.client, i.doc.due-date, sum [(split ' ', ..amount .0 |> parse-int) for i.doc.entries]] for i in res.rows]

        # RECEIPTS
        receipts-default:
            type: \receipt
            product-name: "Ürün Adı"
            contents:
                * material: "Ham madde..."
                  amount: "x kg"
                ...
        receipts-col-names: "Ürün adı"
        receipts-view-generator: (res) ->
            [[i.doc.product-name] for i in res.rows]

        # CUSTOMERS
        customers-default:
            type: \receipt
            product-name: "Ürün Adı"
            contents:
                * material: "Ham madde..."
                  amount: "x kg"
                ...
        customers-col-names: "Ürün adı"
        customers-view-generator: (res) ->
            [[i.doc.product-name] for i in res.rows]



feed = null
ractive.on do
    after-logged-in: ->
        do function on-change
            console.log "running function on-change!"

        feed?.cancel!
        feed := local?.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                on-change!
