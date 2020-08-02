Ractive.decorators.dropdown = (node, opts) ->
    dd = $ node .dropdown opts
    return do
        teardown: ->
