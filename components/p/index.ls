Ractive.components.p = Ractive.extend do
    template: "<div class='ui p {{class}}' bind-style>{{yield}}</div>"
    oninit: ->
        console.warn "You shouldn't use <p> tag, you should use .ui.p instead."

    components:
        p: false
