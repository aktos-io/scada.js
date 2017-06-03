require! 'ractive': Ractive
sleep = (ms, f) -> set-timeout f, ms

Ractive.defaults.has-event = (event-name) ->
    fn = (a) ->
        a.t is 70 and a.n.indexOf(event-name) > -1
    return @component and @component.template.m.find fn


Ractive.events.longpress = (node, fire) ->
    timer = null
    clear-timer = ->
        clear-timeout timer if timer
        timer := null

    mouseDownHandler = (event) ->
        clear-timer!

        timer = sleep 1000ms, ->
            fire {node: node, original: event}

    mouseUpHandler = -> clear-timer!

    node.addEventListener \mousedown, mouseDownHandler
    node.addEventListener \mouseup, mouseUpHandler

    return teardown: ->
        node.removeEventListener \mousedown, mouseDownHandler
        node.removeEventListener \mouseup, mouseUpHandler

window.Ractive = Ractive
