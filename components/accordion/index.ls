Ractive.components['accordion'] = Ractive.extend do
    template: '<div class="ui accordion {{class}}">{{yield}}</div>'
    onrender: -> 
        element = $ @find '.ui.accordion' 
        element.accordion!
        @set 'element', element

    data: -> 
        element: null