/* Usage:
---------------
    radio-buttons(value="{{transfer.state}}" gtrue-color="orange")
        .ui.buttons
            radio-button(value="accepted") Kabul
            radio-button(value="pending" default) Beklemede
*/

Ractive.components['radio-buttons'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
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
                    err <~! @fire \select, {}, new-val
                    return op! unless err
                else
                    return op!

            for btn in buttons
                true-color = (btn.get \true-color) or gtrue-color
                false-color = (btn.get \false-color) or gfalse-color
                btn-val = if btn.get \value => that else btn.partials.content.to-string!
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
                    new-val = if ctx2.get \value => that else instance.partials.content.to-string!
                    unless new-val
                        # FIXME: why do we get a null value?
                        return
                    #console.log "setting value to ", new-val
                    @set-selected-color new-val

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
