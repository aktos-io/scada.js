Ractive.decorators.popup = (node, content) ->
    popup = $ node .popup {content}
    return do
        teardown: ->
            $ node .popup \destroy
