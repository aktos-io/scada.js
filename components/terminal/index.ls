require! 'dcs/browser': {Actor}

actor = new Actor!

Ractive.components["terminal"] = Ractive.extend do
    template: require('./index.pug')
    isolated: yes
    onrender: ->
        actor.subscribe @get \rx-topic

        rx-append = (data) ~>
            @set \rx, (@get(\rx) + data + '\n')

        actor.on \data, (msg) ~>
            rx-append msg.data

        rx-area = $ @find \.rx-area

        @observe \rx, ->
            rx-area.scrollTop rx-area.0.scrollHeight

        @on do
            sendSerial: (ev) ->
                tx-str = @get \tx
                rx-append tx-str 
                actor.send tx-str, @get(\tx-topic)
                actor.log.log "sending: ", tx-str
                @set \tx, ''
                ev.component.fire \state, \done...
