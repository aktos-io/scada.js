require! 'prelude-ls': {filter, each}

empty-item =
    id: null
    content: null
    new-content: null
    is-done: false
    done-timestamp: null
    due-timestamp: null
    new-due-timestamp: null
    can-undone: true
    depends-on: [] # id list of this item dependencies - this item can not bu done unless dependencies are done
    enabled: true # since default depends-on is empty, this must be true
    editing: false

# TODO use aea.merge instead
defaults-merge = (obj, src) !->
    for key of src
        obj[key] = src[key] if not obj.hasOwnProperty key
    return obj

get-index-via-id = (list, id) !->
    for index from 0 to list.length
        return index if list[index].id is id
    return -1

get-item-via-id = (list, id) !->
    for index from 0 to list.length
        return list[index] if list[index].id is id
    return null

dependencies-done = (list, id) !->
    the-index = get-index-via-id list, id
    the-item = list[the-index]

    for dep-id in the-item.depends-on
        dep = get-item-via-id list, dep-id
        return false if not dep.is-done
    return true

# TODO rename this
enable-dependants = (list, id) !->
    for item in list
        if (item.depends-on.indexOf id) > -1
            item-index = get-index-via-id list, item.id
            if dependencies-done list, item.id
                # TODO Call appropriate callbacks
                list[item-index].enabled = true
            else
                # TODO Call appropriate callbacks
                list[item-index].enabled = false
                # TODO Uncheck this is necessary

    return list

Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('todo.pug')
    isolated: true
    oninit: ->
        items = @get \checklist

        # Normalize each and every items in the checklist
        for item in items
            item = defaults-merge item, empty-item

        # Iterate through checklist and set is-done to true if done-timestamp was set
        items
            |> filter (.done-timestamp !== null)
            |> each (.is-done = true)

        @update \checklist

    onrender: ->
        checklist = @get \checklist
        for item in checklist
            new-list = enable-dependants checklist, item.id
        @set \checklist new-list

        @on do
            addNewItem: ->
                new-entry-content = @get \newEntryContent
                checklist = @get \checklist
                log = @get \log

                # add new todo to the list
                new-entry-id = checklist.length + 1
                temp =
                    id: new-entry-id
                    content: new-entry-content
                checklist[*] = defaults-merge temp, empty-item
                @update \checklist

                # reset input via new-entry
                @set \newEntry, empty-item

                # add new action to the log
                log.unshift do
                    action: \new
                    target-id: new-entry-id
                    timestamp: Date.now()
                @update \log

            editItem: (ev, item-id) ->
                checklist = @get \checklist
                the-item = get-item-via-id checklist, item-id

                the-item.new-content = the-item.content
                if theItem.dueTimestamp !== null && theItem.dueTimestamp.toString().length < 13
                    the-item.new-due-timestamp = the-item.due-timestamp * 1000
                else
                    the-item.new-due-timestamp = the-item.due-timestamp
                the-item.editing = true;

                @update \checklist

            saveChanges: (ev, item-id) ->
                checklist = @get \checklist
                log = @get \log
                the-item = get-item-via-id checklist, item-id

                additional = []

                if the-item.new-content is not the-item.content
                    additional[*] =
                        what: \content
                        old-value: the-item.content
                        new-value: the-item.new-content

                    the-item.content = the-item.new-content
                    the-item.new-content = null

                if the-item.new-due-timestamp > 0 && the-item.new-due-timestamp is not the-item.due-timestamp
                    additional[*] =
                        what: \due-timestamp
                        old-value: the-item.due-timestamp
                        new-value: the-item.new-due-timestamp

                    the-item.due-timestamp = the-item.new-due-timestamp
                    the-item.new-due-timestamp = null
                    console.log 'due-timestamp changed'

                the-item.editing = false

                if additional.length > 0
                    console.log additional
                    log.unshift do
                        action: \edit
                        additional: additional
                        target-id: item-id
                        timestamp: Date.now()
                    @update \log

                @update \checklist

            cancelEdit: (ev, item-id) ->
                checklist = @get \checklist
                the-item = get-item-via-id checklist, item-id

                the-item.new-content = null

                the-item.editing = false

                @update \checklist

            statechanged: (ev, curr-state, intended-state, item-id) ->
                checklist = @get \checklist
                log = @get \log
                the-index = get-index-via-id checklist, item-id
                the-item = checklist[the-index]

                # change relevant todo's state
                if intended-state is \checked
                    # check if due-date passed, if so call the callback
                    if the-item.due-timestamp is not null and Date.now() > the-item.due-timestamp
                        @fire \timeout, the-item

                    if not the-item.can-undone
                        ev.component.set \disabled, true

                    the-item.isDone = true
                    the-item.doneTimestamp = Date.now()
                else
                    the-item.isDone = false
                    the-item.doneTimestamp = null

                checklist[the-index] = the-item
                # @update \checklist

                new-list = enable-dependants checklist, item-id
                @set \checklist new-list

                # add new action to the log
                log.unshift do
                    action: intended-state
                    target-id: item-id
                    timestamp: Date.now()
                @update \log

                @fire \statechange ev, checklist, the-index

                @fire \completion if checklist.length == @get \doneItemsLength
    data: ->
        title: 'Todo List'
        checklist:
            * id: 0
              content: 'Dummy Todo'
              is-done: false
              done-timestamp: null
              due-timestamp: null
              enabled: false
              editing: false
            ...
        log: []
        new-entry-content: null
        on-completion: null
        on-statechange: null
    computed:
        itemsLength: ->
            @get \checklist .length
        doneItemsLength: ->
            items = @get \checklist
            doneItems = filter (.isDone), items
            return doneItems.length
