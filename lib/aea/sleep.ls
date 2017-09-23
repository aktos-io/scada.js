export sleep = (ms, f) --> set-timeout f, ms
export after = sleep
export clear-timer = (x) -> clear-interval x
