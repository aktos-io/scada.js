Ractive.components.async = Ractive.extend do
    template: '''
        {{#if (name && @shared.deps[name]) || ready || @shared.deps._all}}
            {{yield}}
        {{elseif @this.partials.loading}}
            {{yield loading}}
        {{else}}
            <div class="ui yellow message">
                We are fetching {{name || 'the'}} component...
            </div>
        {{/if}}
        '''
    data: ->
        ready: no
        name: null
