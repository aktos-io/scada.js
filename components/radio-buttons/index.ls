Ractive.components['radio-buttons'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    on:
        "*.init": (ctx, instance) ->
            true-color = (@get \true-color) or \green
            false-color = @get \false-color
            group = this
            @push \buttons, instance
            set-selected-color = (new-val) ->
                for btn in group.get \buttons
                    btn-val = if btn.get \value => that else btn.partials.content.to-string!
                    if btn-val is new-val
                        btn.set \colorclass, true-color
                    else
                        btn.set \colorclass, false-color

            instance.on \click, (ctx2) ->
                new-val = if ctx2.get \value => that else @partials.content.to-string!
                group.set \value, new-val
                set-selected-color new-val

            # FIXME: this part will run cumulatively (as it is unnecessary )
            if @get \value
                set-selected-color that

    data: ->
        buttons: []



Ractive.components['radio-button'] = Ractive.extend do
    template: RACTIVE_PREPARSE('radio-button.pug')
