require! 'aea': {sleep}

export my-table =
    settings:
        page-size: 20   # optional, 0 or null for infinite page
        default: ->
            # this is the default document for newly created rows
            type: \test
            timestamp: Date.now!
            name: ""
            entries:
                * product: ""
                  amount: ""
                ...
        col-names: "ID of document, Name, Number of entries, some, more, columns"

        on-init: (next) ->
            # fetch your data to `tabledata` variable here

            simulated-data = [{
                _id: ..
                type: \test
                timestamp: .. * 100
                name: "this is #{..}"
                } for [1 to 10]]

            @set \tabledata, simulated-data

            # to continue, call next!
            next!

        on-create-view: (curr, next) ->
            # when you doubleclick a row, this method is called.
            # `curr` is currently clicked document.
            __ = @

            # insert a default value when doubleclicked on a row:
            unless curr.color
                curr.color = "this is a default color"

            @set \curr, curr

            # we might need some time consuming operations within here:
            sleep-duration = 3000ms
            refresh-interval = 1000ms
            remains = sleep-duration
            <- :lo(op) ->
                __.set \openingRowMsg, "doing something for #{sleep-duration} ms, remains: #{remains} ms."
                return op! if remains <= 0
                remains -= refresh-interval
                <- sleep refresh-interval
                lo(op)

            # after you finished row preperation, call next! to continue:
            next!

        filters:
            # define your view filters here.
            # filter your docs here, then return the remaining array:

            all: (docs) ->
                docs

            pink: (docs) ->
                [.. for docs when ..color is \pink]

        handlers:
            # define your event handlers and methods here
            multiply-by-two: (x) ->
                console.log "data-table says: this method multiplies by two!"
                2 * x


        after-filter: (docs, next) ->
            # this method is called after `filter` method is called.
            # create table front view here.

            my-reduce = (x) ->
                try
                    x.length
                catch
                    'not available'

            view = [{
                id: .._id
                cols:
                    .._id
                    ..name
                    my-reduce ..entries
                    \hello
                    \world
                    \again!
                } for docs]

            # call next method when finished:
            next view
