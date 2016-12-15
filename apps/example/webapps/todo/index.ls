require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {
    sleep, unix-to-readable
}
require! './todo-component'

ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('preview.pug')
    onrender: ->
        @on do
            myhandler: ->
                console.log 'all done'
            myTimeoutHandler: (item) ->
                console.log 'timed out...'
                console.log item
    data:
        todos:
            * id: 1
              content: 'This is done by default'
              done-timestamp: 1481776275
            * id: 2
              content: 'This is done by default too'
              is-done: true
              done-timestamp: 1481776275
            * id: 3
              content: 'This can not bu undone'
              can-undone: false
            * id: 4
              content: 'This has a due time'
              due-timestamp: 1481778275
        log: []

        unix-to-readable: unix-to-readable
