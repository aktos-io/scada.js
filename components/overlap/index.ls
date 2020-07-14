sleep = (ms, f) -> set-timeout f, ms

Ractive.components['overlap'] = Ractive.extend do
    template: require('./index.pug')
    onrender: ->
        <~ sleep 10ms
        root = $ @find '.overlap-container'
        max-height = 0
        children = root.children!

        for c in children
            height = $ c .height!
            max-height = height if height > max-height

        root.height max-height
