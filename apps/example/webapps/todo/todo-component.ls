require! 'aea': {
    unix-to-readable
}

Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('todo-component.pug')
    isolated: true
    onrender: ->
        console.log 'todo component rendered'

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
                    done-timestamp: null
                @update \checklist

                # reset input via new-entry
                @set \newEntry,
                    id: null
                    content: null
                    done-timestamp: null

                # add new action to the log
                log[*] =
                    action: \new
                    target-id: newEntryId
                    timestamp: Date.now()
                @update \log

            stateChanged: (ev, curr-state, intended-state, value) ->
                console.log 'state changed id of '
    data: ->
        title: 'Todo List'
        checklist:
            * id: 0
              content: 'Dummy Todo'
              done-timestamp: null
        log: []
        on-completion: null
        new-entry:
            id: null
            content: null
            done-timestamp: null

        unix-to-readable: unix-to-readable
