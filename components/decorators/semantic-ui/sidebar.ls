Ractive.decorators.dropdown = (node, opts) ->
    unless opts
        opts = {}
    unless opts.transition
        opts.transition = \overlay

    sidebar = $ node .sidebar opts
    return do
        teardown: ->
