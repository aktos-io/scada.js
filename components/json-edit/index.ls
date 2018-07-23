require! 'really-relaxed-json': rjson

fixJSON = (x) -> rjson.toJson(x)

Ractive.components['json-edit'] = Ractive.extend do
    template: '''
        <textarea lazy="true"
          style="{{style}}; white-space: pre-wrap; border: {{#if err}}2px dashed red{{else}}1px solid green{{/if}}"
          title="{{err}}"
          class="{{class}}"
          >{{ objFormatted }}</textarea>
        '''
    isolated: yes
    data: ->
        objTmp: null
        value: null
        err: null

    computed:
        objFormatted:
            get: ->
                if @get \objTmp
                    return that
                else
                    return JSON.stringify(@get('value'), null, 2)

            set: (objStr) ->
                try
                    obj = JSON.parse fixJSON objStr
                    @set \value, obj
                    @set \objTmp, null
                    @set \err, null
                catch
                    console.warn "json-edit error was: ", e
                    @set \err, e.message
                    @set \objTmp, objStr
