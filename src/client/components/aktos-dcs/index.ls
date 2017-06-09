require! 'aea/debug-log': {logger}
require! 'aktos-dcs/src/socketio-browser': {SocketIOBrowser}
require! 'aktos-dcs/src/io-actor': {IoActor}
require! 'aktos-dcs/src/filters': {FpsExec}

Ractive.components['aktos-dcs'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    oninit: ->
        __ = @
        new SocketIOBrowser {host: 'http://localhost', port: 4001}
        log = new logger \aktos-dcs-component

        #actor.sync "ractiveVariable", "topic"

        # subscribe to separate topics
        actor = new IoActor pin_name=\my-test-pin1
        actor.ractive = this
        actor.sync "testValue"

        actor2 = new IoActor pin_name=\my-test-pin2
        actor2.ractive = this
        actor2.sync "testValue2"

        # subscribe to same topics
        actor3 = new IoActor \my-test-pin3
        actor3.ractive = this
        actor3.sync "testValue3"

        actor4 = new IoActor \my-test-pin3
        actor4.ractive = this
        actor4.subscribe "IoMessage.hello"
        actor4.sync "testValue4"

        actor5 = new IoActor \my-test-pin4
        actor5.ractive = this
        actor5.subscribe "IoMessage.hello"
        actor5.subscribe "IoMessage.my-test-pin3"
        actor5.sync "testValue5"


    data: ->
        test-value: 0
        test-value2: 0
        test-value3: 0
        test-value4: 0
