require! 'ractive': Ractive

Ractive.defaults.has-event = (event-name) ->
    fn = (a) ->
        a.t is 70 and a.n.indexOf(event-name) > -1
    return @component and @component.template.m.find fn

window.Ractive = Ractive
