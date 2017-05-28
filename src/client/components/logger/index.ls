Ractive.components['logger'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        modal = $ @find '.ui.basic.modal'

        @on do
            show-dimmed: (msg) ->
                modal.modal \show
    data: ->
