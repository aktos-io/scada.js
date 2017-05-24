require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {sleep, unix-to-readable}
require! './simulate-db': {db}
require! './previews/test-data-table/my-table': {my-table}

ractive = new Ractive do
    el: \body
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
        csv-importer:
            show: yes
            test-data: """
                74LPPD2KZ7N,ACILI EZME 200 GR,5T1544H8
                74LPPD2L06J,ACILI EZME 200 GR MEAL BOX,4NL8C89Y
                74LPPD2L08J,ACILI EZME 3000 GR,55LE456H
                """
        input-field: value: null
        combobox:
            show: yes
            selected:
                * id: \aaa
                * id: \bbb
                * id: \ccc
            case2:
                * id: \1
                * id: ""
                * id: \3
                * id: \4
                * id: ""
            products:
                * id: \1
                  name: \apple
                * id: \2
                  name: \strawberry
                * id: \3
                  name: \melon
                * id: \4
                  name: "tomato"
            units:
                * id: \1
                  name: \kg
                * id: \2
                  name: \gr
                * id: \3
                  name: \packet
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

        combobox-list: ->
            @get \combobox.list2

        date-picker:
            show: yes
        checkbox:
            checked1: no
            checked2: no
        file-read:
            show: yes
            files: []
        formal-field:
            show: yes
            value1: 3
            value2: \Paket
            tempvalue:"mahmut"
            combobox:
                * id:\Paket, name:\Paket
                * id:\Koli, name: \Koli
        curr:
            value1: 5
        units:
            * id:\Paket, name:\Paket
            * id:\Koli, name: \Koli
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
        menu: []
        menu-links:
            * title: "Dropdown"
              url: '/dropdown'
              icon: 'tags'
            * title: "İş Planları"
              url: '/production-jobs'
              icon: "industry"
            * title: "Paketleme"
              url: '/bundling'
              icon: 'gift'
            * title: "Sevkiyat"
              submenu:
                * title: "dispatch submenu1"
                  url: '/dispatch/1'
                * title: "dispatch submenu2"
                  url: '/dispatch/2'
                * title: "dispatch submenu3"
                  url: '/dispatch/3'
                * title: "dispatch submenu4"
                  url: '/dispatch/4'

            * title: "Depo İstek Formu"
              url: '/raw-material-requests'
              icon: 'shop'
            * title: "Satın Alma"
              url: '/raw-material-purchases'
              icon: 'shopping bag'
            * title: "Hammadde Kabul"
              url: '/raw-material-admission'
              icon: 'download'
            * title: "Tanımlamalar"
              icon: "settings"
              submenu:
                * title: "Müşteri Tanımla"
                  url: '/definitions/client'
                * title: "Marka Tanımla"
                  url: '/definitions/brands'
                * title: "Tedarikçi Tanımla"
                  url: '/definitions/supplier'
                * title: "Hammadde Tanımla"
                  url: '/definitions/raw-material'
                * title: "Reçete Tanımla"
                  url: '/definitions/recipe'
                * title: "Kap Tanımla"
                  url: '/definitions/container'
                * title: "Paket Tanımla"
                  url: '/definitions/packaging'
                * title: "Çalışan Tanımla"
                  url: '/definitions/workers'
                  icon: 'user'

ractive.on do
    'complete': ->
        __ = @
        <- sleep 10ms
        __.set \menu, __.get \menuLinks

        # initialize sidebar
        $ '.ui.sidebar' .sidebar!
        # use menu in content context
        #$ '.ui.sidebar' .sidebar context: $ 'body .bottom.segment'


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

    test-ack-button5: (ev) ->
        ev.component.fire \info, 'this is a test string (info)'

    test-ack-button4: (ev, value) ->
        console.log "asking if yes or no"
        ok <- ev.component.fire \yesno, do
            title: 'well...'
            message: value or 'are you sure?'

        unless ok
            msg = "User says it's not OK to continue!"
            ev.component.fire \output, msg
            console.error msg
            return

        ok <- ev.component.fire \yesno, do
            title: 'HTML test'
            message: html: """
                <h1>This is header</h1>
                <span class="glyphicon glyphicon-ok-sign" style="font-size: 2em"></span>
                <span>This is an icon...</span>
                """

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

    uploadReadFile: (ev, file, next) ->
        ev.component.fire \state, \doing
        console.log "Appending file: #{file.name}"
        ractive.push 'fileRead.files', file
        /*
        answer <- ev.component.fire \yesno, message: """
            do you want to proceed?
        """
        ev.component.fire \state, \error, "cancelled!" if answer is no
        */
        ev.component.fire \state, \done
        <- sleep 2000ms
        next!

    fileReadClear: (ev) ->
        ractive.set \fileRead.files, []
        ev.component.fire \info, message: "cleared!"

    import-csv: (ev, content) ->
        ev.component.fire \state, \doing
        console.log "content: ", content
        ractive.set \csvContent, content
        ev.component.fire \state, \done...
    test-formal-field: (ev, log-item, finish) ->
        /*
        ev.component.fire \state, \doing
        <- sleep 3000ms
        ev.component.fire \state, \done...
        */
        formal-field = ractive.get \formalField
        formal-field.value1 = log-item.curr.value1
        formal-field.value2 = log-item.curr.value2
        ractive.set \previous, log-item.prev
        formalField.changelog = ev.add-to-changelog log-item
        ractive.set \formalField, formal-field
        finish!

    test-formal-field-show:(ev, log) ->
        string = """
            <table>
                <thead>
                    <tr>
                        <th>Date &nbsp</th>
                        <th>Amount &nbsp</th>
                        <th>Unit &nbsp</th>
                        <th>Message </th>
                    </tr>
                </thead>
                <tbody>
            """

        for row in log
            string += """
                <tr style="text-align:middle;">
                    <td>#{unix-to-readable row.date} &nbsp</td>
                    <td>#{row.curr.value1} &nbsp</td>
                    <td>#{row.curr.value2} &nbsp</td>
                    <td>#{row.message}</td>
                </tr>
                """
        string += """
                </tbody>
            </table>
            """
        ev.component.fire \info, message: html: string

    /*
    delete-product: (i) ->
        products = ractive.get \combobox.products
        products.splice (parse-int i), 1
        ractive.set \combobox.products, products
    */

    delete-products: (i) ->
        products = ractive.get \combobox.case2
        index = parse-int i
        products.splice index, 1
        ractive.set \combobox.case2, products
        debugger
