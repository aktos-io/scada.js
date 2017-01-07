require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {sleep, unix-to-readable}
require! './simulate-db': {db}
require! './previews/test-data-table/my-table': {my-table}

ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('layout.pug')
    data:
        db: db
        my-table: my-table
        button:
            show: yes
            send-value: ''
            bound-val: ''
            info-title: ''
            info-message: ''
            output: 'hello'
        combobox:
            show: yes
            list1:
                * id: \1
                  name: \hello
                * id: \2
                  name: \world
                * id: \3
                  name: \heyy!
                * id: \4
                  name: "çalış öğün"
                * id: \5
                  name: "ÇALIŞ ÖĞÜN"
            list2:
                * id: \aaa
                  name: \totally
                * id: \bbb
                  name: \different
                * id: \ccc
                  name: \list
            boundSelected: null
        date-picker:
            show: yes
        checkbox:
            checked1: no
            checked2: no
        todo:
            show: yes
            todos1:
                * id: 1
                  content: 'This is done by default'
                  done-timestamp: 1481778240000
                * id: 2
                  content: 'This is done by default too'
                  done-timestamp: 1481778242000
                * id: 3
                  content: 'This can not be undone'
                  can-undone: false
                * id: 4
                  content: 'This has a due time'
                  due-timestamp: 1481778240000
                * id: 5
                  content: 'This depends on 1 and 2'
                * id: 6
                  content: 'This depends on 3 and 5 (above one)'

            log1: []
            todos2:
                * id: 1
                  content: 'Do this'
                * id: 2
                  content: 'Do that'
                * id: 3
                  content: 'Finally do this'
            log2: []
        unix-to-readable: unix-to-readable

ractive.on do
    test-ack-button1: (ev, value) ->
        ev.component.fire \state, \doing
        <- sleep 5000ms
        ractive.set \button.sendValue, value
        ev.component.fire \state, \done...

    test-ack-button2: (ev, value) ->
        ev.component.fire \state, \doing
        <- sleep 3000ms
        ev.component.fire \state, \error, "handler 2 got message: #{value}"
        <- sleep 3000ms
        ev.component.fire \state, \done

    test-ack-button3: (ev, value) ->
        ev.component.fire \info, do
            title: "this is an example info"
            message: value or "test info..."

    test-ack-button4: (ev, value) ->
        console.log "asking if yes or no"
        ok <- ev.component.fire \yesno, do
            title: 'Well...'
            message: value or 'are you sure?'

        unless ok
            msg = "User says it's not OK to continue!"
            ev.component.fire \output, msg
            console.error msg
            return

        msg = "It's OK to go..."
        console.log msg
        ev.component.fire \output, msg

    checkboxchanged: (ev, curr-state, intended-state, value) ->
        console.log "checkbox event fired, curr: #{curr-state}"
        ev.component.fire \state, \doing
        <- sleep 2000ms
        ev.component.fire \state, intended-state

    my-print: (html, value, callback) ->
        callback err=null, body: """
            <h1>This is value: #{value}</h1>
            #{html}
            """

    todostatechanged: (ev, list, item-index) ->
        the-item = list[item-index]
        new-state = if the-item.is-done then \checked else \unchecked
        old-state = if new-state is \checked then \unchecked else \checked
        console.log "Bound components: todo item with id of '" + the-item.id + "' state's changed from '" + old-state + "' to '" + new-state + "'"

    todocompletion: ->
        console.log "Bound components: all todo items has been done"

    todotimeout: (item) ->
        console.log "Bound components: item with id of '" + item.id + "' in the list had been timed out"
        console.log item

    todostatechanged2: (ev, list, item-index) ->
        the-item = list[item-index]
        new-state = if the-item.is-done then \checked else \unchecked
        old-state = if new-state is \checked then \unchecked else \checked
        console.log "UnBound instance: todo item with id of '" + the-item.id + "' state's changed from '" + old-state + "' to '" + new-state + "'"

    todocompletion2: ->
        console.log "UnBound instance: all todo items has been done"

    todotimeout2: (item) ->
        console.log "UnBound instance: item with id of '" + item.id + "' in the list had been timed out"
        console.log item
