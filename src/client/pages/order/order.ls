require! 'components'
require! 'aea': {PouchDB, sleep, unix-to-readable, merge}
require! 'prelude-ls': {sum, split, sort-by, flatten, group-by, reverse }

require! './orders-table': {orders, production, material-usage}
require! './recipes-table': {recipes}
require! './raw-materials': {raw-materials}

require! './customers-table': {customers}

db = new PouchDB 'https://demeter.cloudant.com/cicimeze', {+skip-setup}
#local = new PouchDB \local_db

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
        changes: 0

        # SUPPORT
        support:
            default:
                type: \issue
                subject: 'Başlık...'
                date: null
                entries:
                    * author: ''
                      body: ''
                    ...

            col-names: "Konu"
            filters:
            after-filter: (docs, callback) ->
                callback [{id: .._id, cols: [..subject]} for docs]

        orders: orders
        production: production
        material-usage: material-usage
        recipes: recipes
        raw-materials: raw-materials
        customers: customers

        menu-public:
            * title: "Ana Sayfa"
              url: '#/'
            ...

        productList:
            * name: 'Fıstıklı Yaprak Sarması'
              id: 1
            * name: 'Yaprak sarma'
              id: 2
            * name: 'Patlıcan salata'
              id: 3
            * name: 'Patlıcan ezme'
              id: 4
        bbb: null

x=12
feed = null
ractive.on do
    'login.success': ->
        __ = @
        console.log "running after logged in..."
        do function on-change
            console.log "running function on-change!"
            __.set \changes, (__.get \changes) + 1
            err, res <- db.query 'customers/getCustomers', {+include_docs}
            if err
                console.log "ERROR customer list: ", err
            else
                #console.log "customer list updated: ", res
                ractive.set \customersList, [{name: ..doc.name, id: ..doc.key} for res.rows]

        /*
        feed?.cancel!
        feed := local?.sync db, {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                on-change!
        */
        feed?.cancel!
        feed := db.changes {+live, +retry, since: \now}
            .on \error, -> feed.cancel!
            .on 'change', (change) ->
                console.log "change detected!", change
                on-change!

        menu-public = ractive.get \menuPublic
        ractive.set \menu, menu-public ++ menu-private =
            * title: "Siparişler"
              icon: "fa fa-bar-chart-o"
              url: '#/orders'
            * title: "Sevkiyat"
              url: '#/dispatch'
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
            * title: "Ürün Kısaltmaları"
              url: '#/product-map'
            * title: "Destek"
              url: '#/support'

    'login.logout': ->
        ractive.set \menu, ractive.get \menuPublic
