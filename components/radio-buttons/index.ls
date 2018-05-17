/* Usage:
---------------
    radio-buttons(value="{{transfer.state}}" gtrue-color="orange")
        .ui.buttons
            radio-button(value="accepted") Kabul
            radio-button(value="pending" default) Beklemede
*/

Ractive.components['radio-buttons'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    on:
        "*.init": (ctx, instance) ->
            gtrue-color = @get \true-color
            gfalse-color = @get \false-color
            @push \buttons, instance

            set-selected-color = (new-val) ~>
                buttons = @get \buttons
                for btn in buttons
                    true-color = (btn.get \true-color) or gtrue-color
                    false-color = (btn.get \false-color) or gfalse-color
                    btn-val = if btn.get \value => that else btn.partials.content.to-string!
                    if btn-val is new-val
                        @set \value, new-val
                        btn.set \colorclass, true-color
                    else if not new-val? and btn.get \default
                        # set the default value if specified
                        @set \value, btn.get \default
                        btn.set \colorclass, true-color
                    else
                        btn.set \colorclass, false-color

            instance.on \click, (ctx2) ->
                new-val = if ctx2.get \value => that else @partials.content.to-string!
                set-selected-color new-val

            set-selected-color @get \value

    data: ->
        buttons: []
        'true-color': 'green'


Ractive.components['radio-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('radio-button.pug')
    data: ->
        default: false
