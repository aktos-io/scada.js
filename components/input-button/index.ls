/* Usage: 

 input-button(value="{{value}}") {{{{.format(.value).fullText}}}}

*/

Ractive.components['input-button'] = Ractive.extend do
    template: require './index.pug'
    isolated: no
    onrender: ->
        button = $ @find ".#{@_guid}_button"
        popup = button.parent().find('.popup')

        orig-value = null 
        modal = button.parent().find '.ui.modal'
        input = popup.find('input.string_input')

        o = [] # observers 

        o.push @observe 'new_value', (value) ->> 
            @set '_unchanged', (value is orig-value)

        o.push @observe 'value', (value) ->>
            o.for-each (.silence!)
            @set '_unchanged', (value is @get 'new_value')
            @set '_write_error', (value isnt @get 'new_value')
            await @set '_live_value', value
            o.for-each (.resume!)

        o.push @observe '_live_value', (value) ->>  
            o.for-each (.silence!)
            await @set 'value', value 
            await @set 'new_value', value
            o.for-each (.resume!)

        @observe 'error', (value) -> 
            input.prop "disabled", value
    
        # do not start observation on init
        o.for-each (.silence!)

        button.popup do 
            popup: popup
            on: 'click'
            onShow: ~> 
                if @get 'use-modal' then modal.modal 'show'
                @set '_write_error', false
                return not @get('readonly') 

            onVisible: (x) ~>>
                input.on 'keyup', (e) ~> 
                    switch e.key
                    | \Enter => @fire 'accept'
                    | \Escape => button.popup 'hide'

                orig-value := @get 'value'
                await @set 'new_value', orig-value
                await @set '_live_value', orig-value
                input.focus!.select!

                o.for-each (.resume!)

            onHide: (x) ~> 
                if @get 'use-modal' then modal.modal 'hide'
                o.for-each (.silence!)

                return true

        @on do
            accept: (ctx) -> 
                unless @get \error 
                    new_value = @get('new_value')
                    @set 'value', new_value
                    orig-value := new_value
                    @set '_unchanged', (new_value is orig-value)
                    @set '_write_error', false
                    input.focus!.select!

            revert: (ctx) -> 
                @set 'new_value', orig-value
                input.focus!.select!

            close: (ctx) -> 
                button.popup 'hide'
            
    data: -> 
        value: null
        'input-type': 'number'
        new_value: null 
        _unchanged: no 
        _write_error: no 
        'use-modal': no 
        class: ''
        style: ''
        readonly: false
        error: false
        title: null
        step: 1
        min: 0 
        max: null 
        _live_value: null
