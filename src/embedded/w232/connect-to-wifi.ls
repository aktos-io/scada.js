require! 'Wifi'

/*
export connect-to-wifi = !->
    do
        apn <- Wifi.scan
        if cfg.ram.conn.essid not in [..ssid for apn]
            console.log "Falling back to default wifi!"
            cfg.ram.conn = default-wifi

        <- :lo(op) ->
            console.log "trying to connect to wifi...", cfg.ram.conn
            err <-! Wifi.connect cfg.ram.conn.essid, {password: cfg.ram.conn.passwd}
            console.log "connected? err=", err, "info", Wifi.getIP!
            if not err
                console.log "connected to wifi! (according to err)"
                connect-to-server!
            else
                console.log "Error, retrying to connect to wifi..."
                <- sleep 1000ms
                lo(op)

    Wifi.stopAP!
*/

export !function WifiConnect default-settings
    @default-essid = default-settings.essid
    @default-passwd = default-settings.passwd
    @retry-limit = 5
    @retry-count = 0
    @only-default = yes

WifiConnect::new-wifi = (essid, passwd) ->
    @new-essid = essid
    @new-passwd = passwd
    @only-default = no

WifiConnect::connect = (callback) ->
    essid = @default-essid
    passwd = @default-passwd
    err <- Wifi.connect essid, {password: passwd}
    console.log "connected? err=", err, "info", Wifi.getIP!
    if not err
        console.log "connected to wifi! (according to err)"
    callback err
