Ractive.components.p = Ractive.extend do
    template: "<div class='ui p {{class}}' style='{{style}}'>{{yield}}</div>"
    onrender: (ctx) ->
        console.warn "You shouldn't use <p> tag, you should use .ui.p instead:"
        console.warn ctx.element.to-string!

    components:
        p: false
