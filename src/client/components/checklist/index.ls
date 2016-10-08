require! 'prelude-ls': {
    and-list
}
component-name = "checklist"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        @observe \items, (items) ->
            completed = (and-list [..checked for items])
            __.set \completed, completed
            __.fire \complete if completed

    data: ->
        items:
            * id: null
              name: "NO CHECKLIST SPECIFIED"
            ...
        completed: no 
