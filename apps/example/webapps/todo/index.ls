require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {
    sleep,
    # unix-to-readable
}
require! './todo'

unix-to-readable-ms = (unix) ->
  display = moment (new Date unix) .format 'DD.MM.YYYY HH:mm.ss'
  display

ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('preview.pug')
    onrender: ->
        @on do
            # statechanged: (ev, checklist, current-index) ->
            #     console.log [ev, checklist, current-index]
            myhandler: ->
                console.log 'all done'
            myTimeoutHandler: (item) ->
                console.log 'timed out...'
    data:
        todos:
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
              depends-on: [1, 2]
            * id: 6
              content: 'This depends on 3 and 5 (above one)'
              depends-on: [3, 5]
        log: []

        unix-to-readable: unix-to-readable-ms
