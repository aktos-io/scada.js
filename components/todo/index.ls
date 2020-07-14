require! 'prelude-ls': {filter, each, find}
require! 'aea': {merge, unix-to-readable}
require! 'actors': {RactiveActor}
require! uuid4

Ractive.components['todo'] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes

    oninit: ->
        @actor = new RactiveActor this, 'todo'

    onrender: ->
        @on do
            startEditing: (ctx)->
                @set \tmp, ctx.get!
                @set \editingItem, ctx.get \.id

            addNewItem: (ctx) ->
                newItem = @get \newItem
                newItem <<< {id: uuid4!}
                unless newItem.content
                    @actor.send 'app.log.err', do
                        title: 'Todo Error'
                        icon: 'warning sign'
                        message: "Content of a list item can not be empty."
                    return

                # TODO: fire external handler for async handling of saving data
                @push \checklist, newItem

                # add new action to the log
                @unshift \log, do
                    action: \new
                    target-id: newItem.id
                    timestamp: Date.now!

                # reset input via new-entry
                @set \newItem, {}

            saveChanges: (ctx) ->
                @unshift \log, do
                    action: \edit
                    from: ctx.get!
                    to: @get \tmp
                    target-id: ctx.get \.id
                    timestamp: Date.now!

                ctx.set '.', @get \tmp

                # close edit window
                @set \editingItem, -1

            cancelEdit: (ev) ->
                @set \editingItem, -1

            statechanged: (ctx, checked, next) ->
                # add new action to the log
                ctx.set \.isDone, checked
                @unshift \log, do
                    action: if checked => 'completed' else 'undone'
                    target-id: ctx.get \.id
                    timestamp: Date.now!

    data: ->
        unix-to-readable: unix-to-readable
        title: 'Todo List'
        is-editable: false
        editing-item: -1
        newItem: {}
        editingContent: ''
        newDueTimestamp: 0
        checklist: {}
        log: []
        is-editing: (id) ->
            id is @get \editingItem

    computed:
        itemsLength: ->
            @get \checklist .length

        doneItemsLength: ->
            items = @get \checklist
            doneItems = filter (.isDone), items
            doneItems.length
