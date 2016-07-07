{sleep, after, clear-timer} = require './sleep'


wait-events = {}
get-wait-event = (event-id) ->
    ev_ = wait-events[event-id]
    if ev_ is void
        ev_ = {callbacks: [], run: no, waiting: no}
        wait-events[event-id] = ev_
    return ev_

run-waiting-event = (event-id, timer) ->
    ev_ = get-wait-event event-id
    if ev_.waiting and ev_.run
        ev_.run = no
        ev_.waiting = no
        for callback in ev_.callbacks
            status = if timer is null then \timed-out else \has-event
            clear-timer timer  # clear timer if set
            wait-events[event-id] = void
            callback status

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

export go = (event-id) !->
    ev_ = get-wait-event event-id
    ev_.run = yes
    run-waiting-event event-id, "normally-go"
