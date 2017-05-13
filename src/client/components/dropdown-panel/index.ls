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
            
        return
        overlay.resize ->
            if overlay.height! > 0
                overlay.css do
                    border: '1px solid lightgray'
                    'border-top': 'none'
                    'border-radius': '0px 0px 5px 5px'
            else
                overlay.css border: 'none'
