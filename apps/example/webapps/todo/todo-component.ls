require! 'prelude-ls': {filter, each, concat}

empty-item =
    id: null
    content: null
    is-done: false
    done-timestamp: null
    due-timestamp: null
    can-undone: true

Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('todo-component.pug')
    isolated: true
    onrender: ->
        console.log 'todo component rendered'

        # Iterate through checklist and set is-done to true if done-timestamp was set
        items = @get \checklist
        each (-> Object.assign({}, @, empty-item)), items
        # items
        #     |> filter (.done-timestamp !== null)
        #     |> each (.is-done = true)
        console.log items
        # @update \checklist

        @on do
            addNewItem: ->
                newEntry = @get \newEntry
                checklist = @get \checklist
                log = @get \log

                # add new todo to the list
                newEntryId = checklist.length + 1
                checklist[*] =
                    id: newEntryId
                    content: newEntry.content
                    is-done: false
                    done-timestamp: null
                @update \checklist

                # reset input via new-entry
                @set \newEntry, empty-item

                # add new action to the log
                log[*] =
                    action: \new
                    target-id: newEntryId
                    timestamp: Date.now()
                @update \log

            statechanged: (ev, curr-state, intended-state, value) ->
                checklist = @get \checklist
                log = @get \log
                theItem = checklist[value - 1]

                # change relevant todo's state
                if intended-state is \checked
                    # check if due-date passed, if so call the callback
                    if Date.now() > theItem.due-timestamp
                        @fire \timeout, theItem

                    if not theItem.can-undone
                        ev.component.set \disabled, true

                    theItem.isDone = true
                    theItem.doneTimestamp = Date.now()
                else
                    theItem.isDone = false
                    theItem.doneTimestamp = null

                checklist[value - 1] = theItem
                @update \checklist

                # add new action to the log
                log[*] =
                    action: intended-state
                    target-id: value
                    timestamp: Date.now()
                @update \log

                # if all done call the callback
                @fire \completion if checklist.length == @get \doneItemsLength
    data: ->
        title: 'Todo List'
        checklist:
            * id: 0
              content: 'Dummy Todo'
              is-done: false
              done-timestamp: null
              due-timestamp: null
            ...
        log: []
        on-completion: null
        new-entry:
            id: null
            content: null
            is-done: false
            done-timestamp: null
    computed:
        itemsLength: ->
            @get \checklist .length
        doneItemsLength: ->
            items = @get \checklist
            doneItems = filter (.isDone), items
            return doneItems.length
