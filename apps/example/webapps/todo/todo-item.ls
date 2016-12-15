Ractive.components['todo-item'] = Ractive.extend do
    template: RACTIVE_PREPARSE('todo-item.pug')
    isolated: yes
    onrender: ->
        console.log "rendering..."
        @observe \checked, (_new) ->
            @set \timestamp, Date.now! if _new is true

    data:
        checked: no
        timestamp: -1
