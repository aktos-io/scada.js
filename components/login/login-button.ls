Ractive.components['login-button'] = Ractive.extend do
    isolated: yes
    template: require('./login-button.pug')
    onrender: ->
        @on do
            click: (ctx) ->
                @find-component \ack-button .fire \click

            doLogin: (ctx) ->
                actor = ctx.component.actor
                user = @get \user
                password = @get \password
                unless user => return ctx.component.error {message: "User name is required."}
                ctx.component.fire \state, \doing
                err, msg <~ actor.send-request {to: \app.dcs.do-login}, {user, password}
                error = err or msg.data.err
                if error
                    ctx.component.error {message: error}
                else if (try msg.data?.res.auth.session.token)
                    # logged in succesfully, clear the password and username,
                    # go to opening scene
                    @set \user, ''
                    @set \password, ''
                    @fire \success
                    ctx.component.fire \state, \done...
                else
                    debugger
    data: ->
        disabled: no
        enabled: yes
