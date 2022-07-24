## Conditional attribute declaration 

To declare an attribute based on another condition in Pug.js syntax:

```pug
input(value="{{hello}}")
ack-button("{{#if hello}}on-click='@.global.alert()'{{/if}}") helloooo
```
