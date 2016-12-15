Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('todo.pug')
    isolated: true
    onrender: ->
        console.log 'a new instance of todo component initialized'
    data: ->
        to-be-deleted: 'working'
        checklist:
            * id: 0
              content: 'Dummy Todo'
              done-timestamp: null
        log: []
        on-completion: null
        new-entry:
            id: null
            content: null
            done-timestamp: null
