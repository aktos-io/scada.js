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
        input = popup.find('input')

        h1 = @observe 'new_value', (new_value) -> 
            @set '_unchanged', (new_value is orig-value)

        h2 = @observe 'value', (value) -> 
            @set '_unchanged', (value is @get 'new_value')
            @set '_write_error', (value isnt @get 'new_value')

        # do not start observation on init
        h1.silence!
        h2.silence!

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
                input.focus!.select!

                h1.resume!
                h2.resume!

            onHide: (x) ~> 
                if @get 'use-modal' then modal.modal 'hide'
                h1.silence!
                h2.silence!

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
        inline: false
        error: false