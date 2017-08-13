require! 'prelude-ls': {filter, each, find}
require! 'aea': {merge, unix-to-readable}

Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes

    onrender: ->
        # logger utility is defined here
        logger = @root.find-component \logger
        console.error "No logger component is found!" unless logger
        # end of logger utility

        @on do
            startEditing: (event, id)->
                orig = find (.id is id), @get \checklist
                @set \editingItem, id
                @set \editingContent, orig.content
                @set \newDueTimestamp, orig.due-timestamp

            addNewItem: (ev, value) ->
                unless value.content
                    @fire \error, do
                        title: "Append Error"
                        message: "Content can not be empty."
                    return

                # TODO: fire external handler for async handling of saving data
                checklist = @get \checklist

                # add new todo to the list
                new-entry-id = checklist.length + 1

                checklist.push do
                    id: new-entry-id
                    content: value.content
                    dueTimestamp: value.dueTimestamp

                @set \checklist, checklist

                # reset input via new-entry
                @set \newItem, {}

                # add new action to the log
                log = @get \log
                log.unshift do
                    action: \new
                    target-id: new-entry-id
                    timestamp: Date.now()
                @set \log, log

            saveChanges: (ev, orig) ->
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

            statechanged: (ev, curr-state, intended-state, item-id) ->
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

            error: (ev, msg, callback) ->
                msg = {message: msg} unless msg.message
                msg = msg `merge` {
                    title: msg.title or 'This is my error'
                    icon: "warning sign"
                }
                @set \state, \error
                @set \reason, msg.message
                @set \selfDisabled, no
                action <- logger.fire \showDimmed, msg, {-closable}
                #console.log "error has been processed by ack-button, action is: #{action}"
                callback action if typeof! callback is \Function

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
