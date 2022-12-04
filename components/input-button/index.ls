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

        button.popup do 
            popup: popup
            on: 'click'
            onShow: ~> 
                if @get 'use-modal' then modal.modal 'show'
                return not @get('readonly') 

            onVisible: (x) ~>>
                input.on 'keyup', (e) ~> 
                    switch e.key
                    | \Enter => @fire 'accept'
                    | \Escape => button.popup 'hide'

                orig-value := @get 'value'
                await @set 'new_value', orig-value
                input.focus!.select!

            onHide: (x) ~> 
                if @get 'use-modal' then modal.modal 'hide'
                return true

        popup.show!

        @observe 'new_value', (new_value) -> 
            @set '_unchanged', (new_value is orig-value)

        @observe 'value', (value) -> 
            @set '_unchanged', (value is @get 'new_value')

        @on do
            accept: (ctx) -> 
                new_value = @get('new_value')
                @set 'value', new_value
                orig-value := new_value
                @set '_unchanged', (new_value is orig-value)
                input.focus!.select!

            revert: (ctx) -> 
                @set 'new_value', orig-value
                input.focus!.select!
            
    data: -> 
        value: null
        'input-type': 'number'
        new_value: null 
        _unchanged: no 
        'use-modal': no 
        class: ''
        style: ''
        readonly: false
        inline: false