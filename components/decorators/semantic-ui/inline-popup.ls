Ractive.decorators.['inline-popup'] = (node, content) ->
    popup = $ node .popup do
        inline: yes
        on: \click
        last-resort: on 
    return do
        teardown: ->
            $ node .popup \destroy
