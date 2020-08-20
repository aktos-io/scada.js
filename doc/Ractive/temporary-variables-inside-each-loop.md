# Temporary Variable inside an `each` loop: 

        {{#each myobj}}
            {{#with (.foo !== 'bar') as tmp}}

                <li>{{.hello}} tmp is: {{tmp}}</li>
            
            {{/with}}
        {{/each}}

`myobj` is not polluted with the `tmp` variables. 

(see https://gitter.im/ractivejs/ractive?at=5f3decae33878e7e602e58d7)