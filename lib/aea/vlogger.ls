require! './logger': {Logger}

/*
Usage
    vlog = new VLogger this

    # Yes/No dialog
    # ------------------------------------

    answer, data <~ vlog.yesno do
        title: 'Yes or No'
        icon: 'map signs'
        buttons:
            myaction:
                text: 'My Action 2'
                color: \red
                icon: \remove
            myaction2:
                text: 'My Action 2'
                color: \red
                icon: \remove

    # Optionaly you can use a Ractive template 
    # ------------------------------------------
    answer, data <~ vlog.yesno do
        title: 'New Script'
        icon: ''
        closable: yes
        template: '''
            <span>Foo is : {{foo}}</span>
            <div class="ui input">
                <input value="{{filename}}" />
            </div>
            '''
        data: 
            foo: "hello"
        buttons:
            create:
                text: 'Create'
                color: \green
            cancel:
                text: \Cancel
                color: \gray
                icon: \remove

    # Here you will receive `data.filename` from the input.


    # ------------------------------------------------------

    answer:
        type: String of action, 
            One of: `key` of opts.buttons
            - or - 
            "hidden" (if closed without action)

    data: Ractive.data if `template` is passed within the options

    closable: Allow "Escape" key to close the dialgo. Answer is set to "hidden".

    # ------------------------------------------------------

*/

export class VLogger
    (@context, name)->
        @logger = new Logger (name or \VLogger)
        @clog = @logger.log
        @cerr = @logger.err
        @cwarn = @logger.warn

        try
            @modal = @context.root.find-component \logger
        catch
            debugger

        unless @modal
            @logger.err "VLogger class requires 'logger' component. Add it first."
            return

    info: (msg, callback) ->
        if typeof! callback is \Object
            @cerr "DEPRECATED IMMEDIATELY: Do not use opts for VLogger."

        msg = message: msg if typeof! msg is \String
        default-opts =
            title: 'Info'
            icon: 'info sign'
            closable: yes

        @modal.fire \showDimmed, {}, (default-opts <<< msg), callback

    error: (msg, callback) ->
        if typeof! callback is \Object
            @cerr "DEPRECATED IMMEDIATELY: Do not use opts for VLogger."

        msg = message: msg if typeof! msg is \String
        default-opts =
            title: 'Error'
            icon: 'warning sign'
            closable: yes
        @modal.fire \showDimmed, {}, (default-opts <<< msg), callback

    yesno: (msg, callback) ->
        if typeof! callback is \Object
            @cerr "DEPRECATED IMMEDIATELY: Do not use opts for VLogger."

        msg = message: msg if typeof! msg is \String
        default-opts =
            title: 'Yes or No'
            icon: 'map signs'
            closable: no
            buttons:
                no:
                    text: 'No'
                    color: \red
                    icon: \remove

                yes:
                    text: \Yes
                    color: \green
                    icon: \remove
        @modal.fire \showDimmed, {}, (default-opts <<< msg), callback
