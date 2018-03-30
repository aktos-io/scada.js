'''

# Realtime Status:
-------------------

    waiting-init      : Waiting for first update
    normal            : Everything normal
    write-failed      : Write failed
    read-failed       : Read failed (when requested read on demand)
    heartbeat-failed  : Heartbeat failed


'''
require! 'actors': {IoActor}

Ractive.components['sync'] = Ractive.extend do
    isolated: yes
    onrender: ->
        @actor = new IoActor this, (@get \topic)
        @actor.sync \value, (@get \topic), (@get \fps)

        @actor.on \receive, (msg) ~>
            @fire \receive, msg

        @actor.request-update!

    data: ->
        value: null
