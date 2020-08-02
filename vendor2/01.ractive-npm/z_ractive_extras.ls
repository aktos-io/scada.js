# Add Ractive to global window object
# ---------------------------------------------
window.Ractive = require \ractive

# Considered as a footgun, but enabling anyways:
Ractive.defaults.resolveInstanceMembers = true

# add sleep method globally
window.sleep = sleep = (ms, f) -> set-timeout f, ms

# Helper methods
# ---------------------------------------------
# hasAttribute by @evs-chris
# see the example: https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SBTAJgcwSAvgGhAZ3gGYCuAdgMYAuAlgPYkAEYAhrgIIUUxUBGRFCACmD0ADjBoUa9DAEp6wADokFFMRJoA6Zmw5de-egF56xctTqMW7Tjz6CSTALYI5i5RRUwEFIjAYUwKlwNMhpHEToEEgp6ADJY+gEBAKCQsIiSKIoNfnCAGyZ+DSY4hIdneip-QODQ8MjonIR8woRiuQAfDsSU2vSG7NyRAqLHUvoAQgnetPrMxqGRtscNAiqkARLDAD56Jg0GQyP6cpcZGQBuJRUMJVvlEgAlJkoqADc2olxBbWs9O0u1yeL2oH1mGSywQINCkxmerzBCAAHvwSBs3CpFq1IPQAAbXDwUAA8Im2wGA21C0SyGAwRmOBJUKnJAGIqAR6AABLRWXS2fgCADkSMFMlpjMJKgAEqwAMr0AAa9FYABUVY8AJIAIQAqiqAKL0XUq+gAOQA8ibZfqVRLmcAEHlvuL3EzCVKWCcpEi9nz9AhfXs8nk7RRyQB6dm0onh0kS3FYAlIQpMHGmV50AQyDGErw+PzyUNInEkIjBiX3G53GRKTIAd3o8NBghzjpxgu4NCQAE9BYn3Fj+Dj8a7idDvYYFCBydwmDBxSB6NsZfKlar1dq9YbjWbLfRrSqY+PthKicePbgvfQfYUbP7A0xg0eYSf3AmkymcTmVLOYDjSEgCBrJkSAEvcsiYEAA
``
function hasAttribute({ proto }) {
	proto.hasAttribute = function hasAttribute(name) {
		return this.component && ((this.component.template.a && name in this.component.template.a) || (this.component.template.m && !!this.component.template.m.find(a => a.n === name)));
	}
}

Ractive.use(hasAttribute);
``


/***************************************************************************
by @evs-chris, https://gitter.im/ractivejs/ractive?at=59fa35f8d6c36fca31c4e427

Usage in template:

    +each('foo') <--- where curr.components is an Object
        btn.icon(on-click="@.delete('curr.components', @key)") #[i.minus.icon]

Usage in scripting side:

    @delete 'curr.components', 'my_item'
*/
Ractive.prototype.delete = (root, key) ->
    console.error 'keypath must be string' if typeof! root isnt \String
    delete @get(root)?[key]
    @update root


# Usage in scripting side:
#
# @find-wid 'my_wid_id' .fire 'something'
Ractive.prototype.find-wid = (wid) ->
    for x in @find-all-components!
        if (x.get \wid) is wid
            return x

# Usage in scripting side:
#
# @find-id 'the_id' .fire 'something'
Ractive.prototype.find-id = (id) ->
    for x in @find-all-components!
        if (x.get \id) is id
            return x

Ractive.prototype.clone-context = ->
    ctx = @getContext!.getParent yes
    ctx.refire = yes
    return ctx

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
    /***************************************************************************
    Use to find a unique DOM element near the context

    Usage:

        1.  define a DOM element with a unique id:

            <div id="{{@keypath}}-mypostfix" > ... </div>

        2. Find this DOM element within the handler, using ctx:

            myhandler: (ctx) ->
                the-div = ctx.find-keypath-id '-mypostfix'

    ***************************************************************************/
    @ractive.find '#' + Ractive.escapeKey(@resolve!) + postfix


Ractive.Context.removeMe = ->
    /***************************************************************************
    usage:

        +each('something')
            btn.icon(on-click="@context.removeMe()") #[i.minus.icon]
    ***************************************************************************/

    @splice '..', @get('@index'), 1
