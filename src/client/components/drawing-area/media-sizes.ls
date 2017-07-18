Ractive.components['desktop-only'] = Ractive.extend do
    template: ->
        if $ window .width! > 992px
            '{{yield}}'
        else
            ''

Ractive.components['mobile-only'] = Ractive.extend do
    template: ->
        if $ window .width! <= 992px
            '{{yield}}'
        else
            '' 
