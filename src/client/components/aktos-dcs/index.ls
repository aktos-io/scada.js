require! 'aea/debug-log': {logger}
require! 'aktos-dcs/proxy-actor': {ProxyActor}
require! 'aktos-dcs/io-actor': {IoActor}

Ractive.components['aktos-dcs'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        __ = @
        proxy-actor = new ProxyActor!
        actor = new IoActor pin_name=\test-actor
        log = new logger \aktos-dcs-component

        silenced = no
        @observe \testValue, (_new) ->
            if silenced
                silenced := no
                return
            log.log "sending #{_new}"
            actor.send-val _new

        actor.receive = (msg) ->
            @log.log "handle_IoMessage is run within component: ", msg
            silenced := yes
            __.set \testValue, msg.payload.IoMessage.val, {+strict}



    data: ->
        test-value: 0
