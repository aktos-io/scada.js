require! 'dcs': {Actor, Broker}

class Cache extends Actor
    (name='') ->
        super "Cache #{name}"
        @subscribe '**'
        @log.log "subscribed: #{@subscriptions}"

        @cache = {}

        @on-data (msg) ~>
            @cache[msg.topic] = msg.payload
            #@log.log "Current cache status: ", @cache

        @on-update (msg) ~>
            @log.log "update requested from cache"
            for topic, value of @cache
                @send value, topic

    action: ->
        @log.log "#{@name} started..."

new Broker!
new Cache \test
