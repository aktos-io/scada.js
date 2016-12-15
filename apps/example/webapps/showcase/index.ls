require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {sleep}
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

    checkboxchanged: (ev, curr-state, intended-state, value) ->
        console.log "checkbox event fired, curr: #{curr-state}"
        ev.component.fire \state, \doing
        <- sleep 2000ms
        ev.component.fire \state, intended-state
