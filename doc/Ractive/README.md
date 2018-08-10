# Description 

These are tips and some key examples to serve as a cheatsheet in addition to [Ractive's own documentation](https://ractive.js.org/api/). 

## Conditional event declaration

To declare an event based on another condition, use `{{#if ...}}on-myevent="..."{{/if}}`:

```pug
input(value="{{hello}}")
ack-button("{{#if hello}}on-click='@.global.alert()'{{/if}}") helloooo
```

## Properly propagating `.hasListener()` behaviour

When you use `a-component` inside `another-component` and `a-component` relies on `.hasListener()` method, additional care must be taken: (see [extending-components/1](./extending-components.md#1-correctly-propagating-listener-detection]))

## Using another component under the hood 

When you create a `super-component` as a drop in replacement for `a-component`, `context` must be properly propagated: (see [extending-components](./extending-components.md))

## Async Components 

A component might get big in time which may impact page load. To send a component after page load, see [ractive-synchronizer](https://github.com/ceremcem/ractive-synchronizer/). 

In short: 

1. Create a simple component.
2. Use it anywhere you like in your app.
3. When you need to remove it from your main bundle and load asynchronously:
    1. Create a synchronizer proxy with your original component's name

            Ractive.partials.foo = getSynchronizer();

    2. Add `ASYNC` postfix to your original component name

            Ractive.components.fooASYNC = Ractive.extend(...)

    3. Remove `fooASYNC` (and its dependencies) from your bundle and load it any time in the future with any method you like (XHR, websockets, etc...)
    4. Send a signal to the synchronizer when your component is ready.

# Internationalization (i18n)

(see https://github.com/ceremcem/ractive-i18n)
