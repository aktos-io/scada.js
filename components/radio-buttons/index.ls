/* Usage:
---------------
    radio-buttons(value="{{transfer.state}}" gtrue-color="orange")
        .ui.buttons
            radio-button(value="accepted") Kabul
            radio-button(value="pending" default) Beklemede
*/

Ractive.components['radio-buttons'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: no
    oninit: ->
        @set-selected-color = (new-val, opts={}) ~>
            gtrue-color = @get \true-color
            gfalse-color = @get \false-color
            buttons = @get \buttons
            #console.log "radio-buttons: #{@get 'myid'}, buttons: #{buttons.length}"
            <~ :lo(op) ~>
                if opts.outside
                    return op!
                else if @get \async
                    const c = @getContext @target .getParent yes
                    c.refire = yes
                    c.button = opts.ctx.component
                    c.button.state \doing
                    err <~! @fire \select, c, new-val
                    unless err
                        c.button.state \done...
                        return op!
                    else
                        c.button.error err
                else
                    return op!

            for btn in buttons
                true-color = (btn.get \true-color) or gtrue-color
                false-color = (btn.get \false-color) or gfalse-color
                btn-val = if btn.get \value => that else btn.partials.content.0
                if btn-val is new-val
                    @set \value, new-val
                    btn.set \colorclass, true-color
                else if not new-val? and btn.get \default
                    # set the default value if specified
                    @set \value, btn-val
                    btn.set \colorclass, true-color
                else
                    btn.set \colorclass, false-color

        @on do
            "*.init": (ctx, instance) ~>
                @push \buttons, instance
                instance.on \click, (ctx2) !~>
                    new-val = if ctx2.get \value
                        that
                    else
                        x = instance.partials.content
                        console.log "content is: ", x
                        y = try x.0
                        if typeof! y is \String
                            y
                        else
                            null
                    unless new-val
                        # FIXME: why do we get a null value?
                        return
                    console.log "setting value to ", new-val
                    @set-selected-color new-val, {ctx: ctx2}

    onrender: ->
        @observe \disabled, (val) ~>
            for @get \buttons
                ..set \disabled val

        @observe \value, (val) ~>
            @set-selected-color val, {+outside}

    data: ->
        buttons: []
        'true-color': 'green'


Ractive.components['radio-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('radio-button.pug')
    data: ->
        default: false
