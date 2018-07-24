Ractive.components.async = Ractive.extend do
    template: '''
        {{#if fetched}}
            {{yield}}
        {{else}}
            <div class="ui yellow message">
                We are fetching {{name}} component...
            </div>
        {{/if}}
        '''
    oninit: ->
        @observe \@shared.deps, (value) ->
            if value
                console.log "All dependencies seem to be fetched."
                @set \fetched, true

    data: ->
        fetched: false
        name: 'the'
