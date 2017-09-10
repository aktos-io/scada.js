require! 'aea': {sleep, VLogger}

Ractive.components['checkbox'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        if @get \class
            if that.index-of(\transparent)  > -1
                @set \transparent, yes

    onrender: ->
        logger = new VLogger this, \checkbox


        @observe \checked, (checked) ~>
            @set \checkState, if checked
                \checked
            else
                \unchecked

        @on do
            _statechange: (ctx) ->
                if @has-event 'statechange'
                    ctx.component.fire \state, \doing

                    ctx.component.observe-once \state, (_new) ~>
                        logger.clog "state changed: ", _new
                        @set \checkState, if @get \checked
                            \checked
                        else
                            \unchecked

                    @set \checkState, \doing
                    checked = @get \checked
                    checked = not checked

                    ctx.logger = logger
                    err, callback <~ @fire \statechange, ctx, checked

                    if arguments.length isnt 1
                        logger.cerr "statechange callback should have exactly
                            1 argument, #{arguments.length} is given."
                        return

                    if err
                        logger.error err, callback
                    else
                        logger.clog "no error returned, toggling checkbox"
                        @set \checkState, if checked
                            \checked
                        else
                            \unchecked

                        @set \checked, checked
                    ctx.component.fire \state, \done

                else
                    checked = @get \checked
                    checked = not checked
                    @set \checkState, if checked
                        \checked
                    else
                        \unchecked

                    @set \checked, checked

    data: ->
        checked: no
        checkState: \unchecked
        transparent: no
