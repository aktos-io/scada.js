# Description 

These are tips and some key examples to serve as a cheatsheet in addition to Ractive's own documentation. 

### Conditional Event Declaration

To declare an event based on another condition, use `{{#if ...}}on-myevent="..."{{/if}}`:

```pug
input(value="{{hello}}")
ack-button("{{#if hello}}on-click='@.global.alert()'{{/if}}") helloooo
```

### Properly propagating `.hasListener()` behaviour

(see [1](./extending-components.md#1-correctly-propagating-listener-detection]))

### Using another component under the hood 

(see [./extending-components](./extending-components.md))

### Async Components 

A component might get big in time which may impact page load. To send a component after page load, see [ractive-synchronizer](https://github.com/ceremcem/ractive-synchronizer/). 

