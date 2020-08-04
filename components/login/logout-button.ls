Ractive.components['logout-button'] = Ractive.extend do
    isolated: yes
    template: require('./logout-button.pug')
    onrender: ->
        @on do
            click: (ctx) ->
                @find-component \ack-button .fire \click

            doLogout: (ctx) ->
                ctx.component.fire \state, \doing
                timeout = 3000ms
                req = {route: \app.dcs.do-logout, timeout, debug: @get('debug')}
                err, msg <~ ctx.actor.send-request req
                if err
                    console.warn "Something went wrong on logout: ", err
                    return
                ctx.component.fire \state, \done...

    data: ->
        disabled: no
        enabled: yes
