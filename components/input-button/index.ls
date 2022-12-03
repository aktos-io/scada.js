/* Usage: 

 input-button(value="{{value}}") {{{{.format(.value).fullText}}}}

*/

Ractive.components['input-button'] = Ractive.extend do
    template: require './index.pug'
    isolated: no
    onrender: ->
        button = $ @find \.button
        popup = button.parent().find('.popup')

        orig-value = null 
        modal = button.parent().find '.ui.modal'

        button.popup do 
            popup: popup
            on: 'click'
            onShow: -> 
                if @get 'use-modal' then modal.modal 'show'
                return true 

            onVisible: (x) ~> 
                input = popup.find('input')
                    ..focus (.target.select!)
                    ..focus!
                    ..on 'keypress', (e) ~> 
                        if e.which is ENTER_KEY=13
                            @fire 'accept'
                orig-value := @get 'value'
                @set 'new_value', orig-value


            onHide: (x) ~> 
                if @get 'use-modal' then modal.modal 'hide'
                return true

        @observe 'new_value', (new_value) -> 
            @set '_unchanged', (new_value is orig-value)

        @on do
            accept: (ctx) -> 
                new_value = @get('new_value')
                @set 'value', new_value
                orig-value := new_value
                @set '_unchanged', (new_value is orig-value)

            cancel: (ctx) -> 
                @set 'new_value', orig-value
            
    data: -> 
        value: null
        'input-type': 'number'
        new_value: null 
        _unchanged: no 
        'use-modal': no 