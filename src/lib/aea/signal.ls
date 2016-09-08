{sleep, after, clear-timer} = require './sleep'
require! './debug-log': {get-logger}


wait-events = {}
get-wait-event = (event-id) ->
    ev_ = wait-events[event-id]
    if ev_ is void
        ev_ =
            callbacks: []
            run: no
            waiting: no
            param: {}

        wait-events[event-id] = ev_
    return ev_

export is-waiting = (event-id) ->
    ev_ = wait-events[event-id]
    if ev_?
        return ev_.waiting
    else
        return no

run-waiting-event = (event-id, timer) ->
    ev_ = get-wait-event event-id
    if ev_.waiting and ev_.run
        ev_.run = no
        ev_.waiting = no
        for callback in ev_.callbacks
            status = if timer is null then \timed-out else \has-event
            clear-timer timer  # clear timer if set
            wait-events[event-id] = void
            callback status, ev_.param

export wait-for = (event-id, callback) !->
    ev_ = get-wait-event event-id
    if callback.to-string! not in [..to-string! for ev_.callbacks]
        ev_.callbacks ++= [callback]
    ev_.waiting = yes
    run-waiting-event event-id

export timeout-wait-for = (timeout, event-id, callback) !->
    ev_ = get-wait-event event-id
    if callback.to-string! not in [..to-string! for ev_.callbacks]
        ev_.callbacks ++= [callback]
    ev_.waiting = yes
    timer = after timeout, ->
        ev_.run = yes
        run-waiting-event event-id, null
    run-waiting-event event-id, timer

export go = (event-id, param) !->
    ev_ = get-wait-event event-id
    ev_.run = yes
    ev_.param = param if param?
    run-waiting-event event-id, "normally-go"

/*
EXAMPLE FOR USE GO!
do
    console.log "waiting mahmut..."
    reason, param <- timeout-wait-for 10000ms, \mahmut
    console.log "mahmut happened! reason: ", reason, "param: ", param

do
    console.log "firing mahmut in 2 seconds..."
    <- sleep 2000ms
    go \mahmut, 5
    console.log "fired mahmut event!"

*/

export watchdog = (name, timeout, callback) ->
    <- :lo(op) ->
         reason <- timeout-wait-for timeout, name
         if reason is \timed-out
             callback!
             return op!
         lo(op)

export watchdog-kick = (name) ->
    go name


/*
log = get-logger "WATCHDOG"
do
    log "started watchdog"
    <- watchdog \hey, 1000ms
    log "watchdog barked!"


do
    i = 0
    <- :lo(op) ->
        log "kicking watchdog, i: ", i
        watchdog-kick \hey
        <- sleep 500ms + (i++ * 100ms)
        lo(op)
*/
