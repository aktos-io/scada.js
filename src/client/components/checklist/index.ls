
require! 'prelude-ls': {
    and-list
}
component = require \path .basename __dirname
Ractive.components[component] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        __ = @
        @observe \items, (items) ->
            if items
                completed = (and-list [..checked for items])
                __.set \completed, completed
                __.fire \complete if completed

    data: ->
        items:
            * id: null
              name: "NO CHECKLIST SPECIFIED"
              checked: no
            ...
        completed: no
