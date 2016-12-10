require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {
    sleep, unix-to-readable
}
require! './todo-item'

ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('home-page.pug')
    data:
        new-entry:
            id: null
            content: null
            done-timestamp: null

        todos:
            * id: 1
              content: \foo
              done-timestamp: null
            * id: 2
              content: \bar
              done-timestamp: null
            * id: 3
              content: \baz
              done-timestamp: null

        unix-to-readable: unix-to-readable

ractive.on do
    'addNewItem': (ev, val) ->
        ev.component.fire \state, \doing
        if val.content is \hello
            return ev.component.fire \state, \error, "hi!"
        <- sleep 1000ms
        todos = ractive.get \todos
        todos.push JSON.parse JSON.stringify val
        ractive.set \todos, todos
        ev.component.fire \state, \done...
