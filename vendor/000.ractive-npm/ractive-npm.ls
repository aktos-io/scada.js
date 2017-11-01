require! 'ractive': Ractive
sleep = (ms, f) -> set-timeout f, ms

# Helper methods
# ---------------------------------------------
Ractive.defaults.has-event = (event-name) ->
    fn = (a) ->
        a.t is 70 and a.n.indexOf(event-name) > -1
    return @component and @component.template.m.find fn

# by @evs-chris, https://gitter.im/ractivejs/ractive?at=59fa35f8d6c36fca31c4e427
Ractive.prototype.delete = (root, key) ->
    delete @get(root)[key]
    @update root

# Events
# ---------------------------------------------
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

# Context helpers
# ---------------------------------------------
Ractive.Context.find-keypath-id = (postfix='') ->
    """
    Use to find a unique DOM element near the context

    Usage:

        1.  define a DOM element with a unique id:

            <div id="{{@keypath}}-mypostfix" > ... </div>

        2. Find this DOM element within the handler, using ctx:

            myhandler: (ctx) ->
                the-div = ctx.find-keypath-id '-mypostfix'

    """
    @ractive.find '#' + Ractive.escapeKey(@resolve!) + postfix

Ractive.Context.removeMe = ->
    @splice '..', @get('@index'), 1

# Add Ractive to global window object
# ---------------------------------------------
window.Ractive = Ractive
