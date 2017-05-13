Ractive.components['dropdown-panel'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    onrender: ->
        body = $ @find '.dropdown-body'
        overlay = $ @find '.dropdown-overlay'

        body.popup do
            popup: overlay
            on: \click
            inline: yes
