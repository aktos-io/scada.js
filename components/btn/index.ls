Ractive.components['btn'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    on:
        _click: (ctx) ->
            const c = ctx.getParent yes
            c.refire = yes
            @fire 'buttonclick', c, @get \value

    data: ->
        type: 'default'
        value: ''
        class: ''
        style: ''
        disabled: false
