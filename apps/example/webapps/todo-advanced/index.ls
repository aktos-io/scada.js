require! 'prelude-ls': {group-by, sort-by}
require! components
require! 'aea': {
    sleep, unix-to-readable
}
require! './components/todo'

ractive = new Ractive do
    el: '#main-output'
    template: RACTIVE_PREPARSE('pages/preview.pug')
    data:
    #     new-entry:
    #         id: null
    #         content: null
    #         done-timestamp: null
        my-checklist:
            * title: \foo
            * title: \bar
            * title: \baz
    #     unix-to-readable: unix-to-readable

# ractive.on do
#     'addNewTodo': (ev, val) ->
#         console.log ev
#         # ev.component.fire \state, \doing
#         # if val.content is \hello
#         #     return ev.component.fire \state, \error, "hi!"
#         # <- sleep 1000ms
#         # todos = ractive.get \todos
#         # todos.push JSON.parse JSON.stringify val
#         # ractive.set \todos, todos
#         # ev.component.fire \state, \done...
