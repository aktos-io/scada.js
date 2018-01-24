Ractive.components['debug-obj'] = Ractive.extend do
    template: RACTIVE_PREPARSE('index.pug')
    isolated: yes
    computed:
        objFormatted:
            get: ->
                if @get \objTmp
                    return that
                else
                    return JSON.stringify(@get('obj'), null, 2)
            set: (obj-str) ->
                try
                    obj = JSON.parse(obj-str)
                    @set \obj, obj
                    @set \objTmp, null
                catch
                    @set \objTmp, obj-str
