Ractive.decorators.['accordion'] = (node, content) ->
    accordion = $ node .accordion!

    return do
        teardown: ->
            #$ node .popup \destroy
