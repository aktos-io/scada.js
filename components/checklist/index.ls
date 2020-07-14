
require! 'prelude-ls': {
    and-list
}
Ractive.components['checklist'] = Ractive.extend do
    template: require('./index.pug')
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
