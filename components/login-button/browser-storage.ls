require! 'aea': {Logger}
require! 'dcs/browser': {BrowserStorage}


Ractive.components['browser-storage'] = Ractive.extend do
    isolated: yes
    template: ''
    oninit: ->
        @log = new Logger \BrowserStorage
        if @get \db
            db = that
        else
            @log.err "db parameter is required!"
            return

        storage = new BrowserStorage db

        key = @get \key
        @set \value, try
            storage.get key
        catch
            console.error "error while getting key #{key} from browser-storage: ", e
            null

        #@log.log "set initial value: ", @get \value

        @observe \value, (_new) ->
            storage.set key, _new
            #@log.log "saving new value to browser storage: ", _new
