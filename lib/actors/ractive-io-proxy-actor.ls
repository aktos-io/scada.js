require! 'dcs/proxy-actors/io-proxy/io-proxy-client': {IoProxyClient}

# see components/sync as an example 
export class RactiveIoProxyClient extends IoProxyClient
    (@ractive, opts) ->
        super opts

        # This is the most important part of RactiveActor
        # ----------------------------------------------------------------------
        @ractive.on do
            teardown: ~>
                #@log.log "Ractive actor is being killed because component is tearing down"
                @kill \unrender
        # ----------------------------------------------------------------------
