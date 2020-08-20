# Temporary Variable inside an `each` loop: 

        {{#each myobj}}
            {{#with (.foo !== 'bar') as tmp}}

                <li>{{.hello}} tmp is: {{tmp}}</li>
            
            {{/with}}
        {{/each}}

`myobj` is not polluted by the `tmp` variables. 

(see https://gitter.im/ractivejs/ractive?at=5f3decae33878e7e602e58d7)

> If you prefer to fill your original object permanently with the generated values, 
> use `{{@context.set()}}`: 
> 
>        {{#each myobj}}
>            {{@context.set('.tmp', (.foo !== 'bar')) && ''}}
>
>            <!-- attention to the dot in front of variable -->
>            <li>{{.hello}} tmp is: {{.tmp}}</li>  
>
>        {{/each}}
