require! 'dcs/browser': {CouchDcsClient}

'''
views:
    get-issues:
        /*
         * list all issues (used in /issues page)
         *
         */
        map: (doc) ->
            if doc.type is \issue
                emit [doc.timestamp, doc._id], do
                    subject: doc.subject
                    labels: doc.labels
'''

doc-type = \issue
export settings =
    name: "#{doc-type}"
    autoincrement: yes
    # define how many rows per page (0 or null for infinite table)
    page-size: 10

    # this is the default document for newly created rows
    default: ->
        _id: 'ISSUE-####'
        type: doc-type

    # column names for the table view
    col-names:
        "ID"
        "Subject"
        "Labels"

    # create tableview here.
    after-filter: (items, next) ->
        view = for items
            id: ..id
            cols:
                ..key.1
                ..value.subject
                (try ..value.labels.join ', ') or ''

        # call next method when finished:
        next view

    # when data table first renders, this function is run:
    on-init: (next) ->
        db = new CouchDcsClient route: "@db-proxy"
            ..on-topic 'db.*.changes.view.issues/getIssues', (msg) ~>
                @fire \kickChanges

            ..on-topic 'app.dcs.connect', (msg) ~>
                @fire \kickChanges
            
        @set \db, db
        next!

    on-create-view: (row, next) ->
        if row
            # editing an existing document
            @logger.clog "opening #{row.id}"
            err, curr <~ @get \db .get row.id, {timeout: 5_000ms}
            if err
                return @logger.error err
            @set \curr, curr
            next!
        else
            # adding new
            next!

    handlers:
        kickChanges: (ctx) ->
            ctx.component?.fire \state, \doing
            err, res <~ @get \db .view 'issues/getIssues', {+descending}
            if err => return ctx.component?.error err
            @set \tableview, res
            ctx.component?.fire \state, \done...
