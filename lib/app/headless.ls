require! 'dcs/browser': {Actor}
require! 'aea': {sleep}

export headless-controls = -> 
    actor = new Actor!
    login = (user, password, opts) ->>
        await actor.send-request {to: \app.dcs.do-login, debug: opts?debug}, {user, password}

    _resolve = null 
    is_completed = new Promise (resolve, reject) -> 
        _resolve := resolve

    mark_completed = -> 
        _resolve!

    return {actor, login, is_completed, mark_completed}

# Like Ractive.fire() but returns a Promise instead
window.fire2 = (instance, event_name, ...args) ->
    ctx = instance.getContext!
    promise = new Promise (resolve, reject) ->
        ctx.reject := reject
        ctx.resolve := resolve

    args.unshift event_name, ctx 
    instance.fire.apply instance, args 
    return promise

window.sleep = sleep