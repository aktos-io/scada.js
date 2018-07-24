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
    data: ->
        fetched: false
        name: 'the'
