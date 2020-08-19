'''
Temporary Variable inside an `each` loop: 

        {{#each myobj}}
            {{ @context.set('._tmp1', (.foo !== 'bar')) && '' }}
            ...
        {{/each}}

or by using `<tmp />` component:

        {{#each myobj}}
            <tmp key="._tmp1" value="{{.foo !== 'bar'}}" /> 
            ...
        {{/each}}

'''
Ractive.components['tmp'] = Ractive.extend do 
    template: ''
    isolated: no 
    on:
        init: (ctx) -> 
            ctx.set @get('key'), @get('value')
