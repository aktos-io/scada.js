require! 'aea': {Logger}
require! 'actors': {BrowserStorage}


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

        [full-addr, hash] = String window.location .split '#'
        app-id = full-addr

        storage = new BrowserStorage "#{app-id}.#{db}"

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
