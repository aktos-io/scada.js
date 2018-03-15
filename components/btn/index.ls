Ractive.components['btn'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    on:
        _click: (ctx) ->
            const c = ctx.getParent yes
            c.refire = yes
            @fire 'buttonclick', c, @get \value
            @fire \click, c
            # prevent event propogation
            return false
    data: ->
        type: 'default'
        value: ''
        class: ''
        style: ''
        disabled: false
