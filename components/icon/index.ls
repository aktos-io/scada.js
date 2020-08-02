Ractive.components.icon = Ractive.extend do
    template: require('./index.pug')
    data: ->
        add: null
        size: ''
        class: ''

Ractive.components.icons = Ractive.extend do
    template: '<b>DEPR!</b>{{yield}}'
    oninit: ->
        console.warn '''
            DEPRECATED: The 'icons' component is deprecated, use 'icon(add="...")' instead
            '''
