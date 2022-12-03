
Ractive.decorators.['accordion'] = (node, open-index) ->
    accordion = $ node .accordion!
    if open-index?
        accordion.accordion 'open', open-index
    return do
        teardown: ->
            #$ node .popup \destroy
