# Proxying Events

Proxying events is somewhat tricky. Parent component MUST take into account that
the child component might depend on

1. Setting its mode by detecting the existence of a specific listener via `@hasListener`
2. Performing context operations by `(ctx, ...) -> ctx.set...`


### 1. Correctly propagating listener detection

Parent should ALWAYS pass event listeners to the child conditionally. In parent
component (`bar`)'s template:

```pug
foo("{{#if @this.getContext().hasListener('y')}}on-x='y'{{/if}}")
```

When you use `bar` as follows, `foo` will detect its `x` listener correctly:

```pug
bar(on-y="hello") has listener
bar has no listener
```

(see https://github.com/ractivejs/ractive/issues/3253)

### 2. Correctly passing the parent context

Problem: A child component's event may be intended to use for:

- either: setting the context inside parent component template
- or: setting the context where the parent component is used

In most cases, you would want to set the parent component's context. So you need to
create a MITM in the event chain.

In Parent component, you define a listener that fires actual event with correct context.
For example, in `component-dropdown` template (which uses `dropdown` under the hood):

```pug
span ComponentDropdown:
dropdown(
    "{{#if @this.getContext().hasListener('select')}}on-select='_select'{{/if}}"
    ...
)
```
and manually define `_select` listener like so:

```ls
    ...
    onrender: (ctx2) ->
        const c = ctx2.getParent yes
        @on do
            _select: (ctx, selected, proceed) ->
                ctx.set = ~> c.set ...arguments
                ctx.get = ~> c.get ...arguments
                @fire \select, ctx, selected, proceed
```
