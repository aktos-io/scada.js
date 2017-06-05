require! 'aea': {sleep}

require! './simulate-data': {
    simulated-data, simulated-timeouts
}

export my-table =
    settings:
        # define how many rows per page (0 or null for infinite page)
        page-size: 5

        # this is the default document for newly created rows
        default: ->
            type: \test
            timestamp: Date.now!
            name: ""
            entries:
                * product: ""
                  amount: ""
                ...

        # column names for the table view
        col-names:
            "ID of document"
            "Name"
            "Number of entries"
            "Color"
            "Foo"
            "Bar"

        # when data table first renders, this function is run:
        on-init: (next) ->
            # fetch your data to `tabledata` variable here
            @set \tabledata, simulated-data

            # display "loading" part for 3 seconds
            <- sleep simulated-timeouts.first-loading-time

            # to continue, call next!
            next!

        # when you doubleclick a row, this method is called.
        on-create-view: (curr, next) ->
            # `curr` is currently clicked document.
            __ = @

            # insert a default value when doubleclicked on a row:
            unless curr.color
                curr.color = "this is a default color"

            @set \curr, curr

            # some simulated time consuming operation here
            sleep-duration = simulated-timeouts.row-opening-time
            refresh-interval = 200ms
            remains = sleep-duration
            <- :lo(op) ->
                __.set \openingRowMsg, "doing something for #{sleep-duration} ms, remains: #{remains} ms."
                return op! if remains <= 0
                remains -= refresh-interval
                <- sleep refresh-interval
                lo(op)

            # after you finished row preperation, call next! to continue:
            next!

        # define your view filters here.
        filters:
            # filter your docs here, then return the remaining array:
            all: (docs) ->
                docs

            pink: (docs) ->
                [.. for docs when ..color is \pink]

        # define your event handlers and methods here
        handlers:
            multiply-by-two: (x) ->
                console.log "data-table says: this method multiplies by two!"
                2 * x


        # this method is called after `filter` method is called.
        # create tableview here.
        after-filter: (docs, next) ->
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
                    "<div class='ui #{..color} label'>#{..color}</div>"
                    \world
                    \again!
                } for docs]

            # call next method when finished:
            next view
