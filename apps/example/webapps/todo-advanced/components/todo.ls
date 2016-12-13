Ractive.components['todo'] = Ractive.extend do
    template: RACTIVE_PREPARSE('todo.pug')
    isolated: true
    data:
        new-todo-title: ''
        checklist:
            * id: null
              title: ''
        log: []
    computed:
        todosCount: ->
            todos = @get \checklist
            todos.length
        doneTodosCount: ->
            todos = @get \checklist
            count = 0
            for todo in todos
                count += 1 if todo.is-completed is true
            # call completion callback if every todo has done
            @.fire \completion if count === @todosCount
            log.push {
                action: 'all-done'
                at: Date.now
            }
            return count
    oninit: ->
        @on do
            \addNewTodo, (ev) ->
                todos = @get \checklist
                todos.push {
                    id: @get \todosCount
                    title: @get \newTodoTitle
                    'is-completed': no
                }
                @set \todos, todos
            stateChange: (ev) ->
                log.push {
                    event: ev
                    action: 'done'
                    timestamp: Date.now
                }
