require! 'prelude-ls': {filter, each, find}
require! 'aea': {merge, unix-to-readable}

Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes

    onrender: ->
        @on do
            startEditing: (event, ev, id)->
                orig = find (.id is id), @get \checklist
                @set \editingItem, id
                @set \editingContent, orig.content
                @set \newDueTimestamp, orig.due-timestamp

            addNewItem: (event, ev, value) ->
                # TODO: fire external handler for async handling of saving data
                checklist = @get \checklist

                # add new todo to the list
                new-entry-id = checklist.length + 1

                checklist.push do
                    id: new-entry-id
                    content: value

                @set \checklist, checklist

                # reset input via new-entry
                ev.component.fire \value, ''

                # add new action to the log
                log = @get \log
                log.unshift do
                    action: \new
                    target-id: new-entry-id
                    timestamp: Date.now()
                @set \log, log

            saveChanges: (event, ev, orig) ->
                _new =
                    content: @get \editingContent
                    due-timestamp: @get \newDueTimestamp

                log = @get \log
                log.unshift do
                    action: \edit
                    summary:
                        what: \due-timestamp
                        old-value: orig.due-timestamp
                        new-value: _new.due-timestamp
                    target-id: orig.id
                    timestamp: Date.now!

                orig `merge` _new
                @update \checklist

                # close edit window
                @set \editingItem, -1

            cancelEdit: (ev) ->
                @set \editingItem, -1

            statechanged: (event, ev, curr-state, intended-state, item-id) ->
                # add new action to the log
                item = find (.id is item-id), @get \checklist
                item.is-done = intended-state is \checked
                log = @get \log
                log.unshift do
                    action: intended-state
                    target-id: item-id
                    timestamp: Date.now!
                @set \log, log
                @update \checklist

    data: ->
        unix-to-readable: unix-to-readable
        title: 'Todo List'
        is-editable: false
        editing-item: -1
        newContent: ''
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
