# ORDERS
export orders:
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
        change-production-state: (order-id, state) ->
            if state not in <[ done aborted ]>
                console.log "Unauthorized state: ", state
                return


            db = @get \db
            tabledata = @get \tabledata
            __ = @


            orders-edited = [.. `merge` {state: state} for tabledata when .._id is order-id]
            console.log "changed state for this document: ", orders-edited

            err, res <- db.bulk-docs orders-edited, {+all_or_nothing}
            if not err
                console.log "All intended orders' states are changed. response: ", res
                [.. `merge` order for tabledata for order in orders-edited when .._id is order._id]

                curr = __.get \curr
                __.set \curr, x = [.. for orders-edited when .._id is curr._id].0
                console.log "current updated document : ", x
            else
                console.log "ERR on change state: ", err



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
                [.. `merge` order for tabledata for order in orders-edited when .._id is order._id]

                curr = __.get \curr
                __.set \curr, [.. for orders-edited when .._id is curr._id].0
            else
                console.log "ERR on change state: ", err

        get-curr-usage: ->
            curr = @get \curr
            console.log "GET_CURR_USAGE: current order: ", curr
            get-material-usage get-production-items curr
