# Proxying Events

Proxying events is somewhat tricky. Parent component MUST take into account that
the child component might depend on

1. Setting its mode by detecting the existence of a specific listener via `@hasListener`
2. Performing context operations by `(ctx, ...) -> ctx.set...`


### 1. Correctly propagating listener detection

Parent should ALWAYS pass event listeners to the child conditionally. In parent
component (`bar`)'s template:

```pug
foo("{{#if @context.hasListener('y')}}on-x='y'{{/if}}")
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
create a MITM in the event chain. ([Playground](https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SBTAJgcwSAvgGhAZ3gEoCGAxgC4CWAbggHQkD2AtgA4MB2C7ZutAZgwYACALxDi5anQQAPMlyQAKYAB12KsvNYAbIvMhCABmo0aAPACMArpo4A+E2VNlgwAMQU+QgAJkwFXhYiGEoibV4SK1wyZgwMR2cNVztI6Nj49Scs1wRwhDiErKTgAE8KXKQ4oULigHpPAsznVxLGxJd3Tx9GblkyWjAiXAAZAPlOGEUAclxchHIprCEyGCsEAEo2oqyzXCD2IWiS7QQRFRBGbQYYAxhkc7tFAHdrgGsKdhR1s1q9onYHE1ssB6nwtuZatZbADDFhHBw7uwkAgbkI+FZ2JIOIpyDJ1qogVRgkISKISWQZLQ0GQAArBLhkRQrNbrADcJNodz4FDuZOZCHZhVmZAAkr0YETtIpFOtRHYhAT2n4ArQiEglFMZFM2TVNP5eNy7tNZicFksSEtlbxqdMtesdUDsEIAIwABndDo02EcSD0RAM6MxlGx+MKdzIVhgB0V2xkBldcKBGhKBnOyL4RCs2icIEKGS9agw6xM7AklBo9GYbE43FwAG1zrgrCwUQBaAQMc4AXTJZaktD6CmUji0LF0+iMhTMHaEJTOeGbKJgMHO1STHQ8Xm8PXkcgGQ1G0S4KONczN-M2GA4rZN8zI84A+rfyOdXKDwVlAe1XG4giEKGEJJRDETAfs4UIxAcjAYmQCrADIYEdLUf6hNoH4-B2X5kLC8LsAYMYaE+Z5kAGGJYuwOIUkstA0cEKC4KG65EjAJJkriVIILS9LcEyqwbOyJCcgghoIHyfGsrqVr8DyCCnqaZCLCS1G0TA9Gelk+ZkBkRYlpwTziKQ5ayTGuQGFMFgMEgJSLCOCA6HoCAGMYQJmGAABMdgAMJ3HoHwoIci4wK2jCsBwDK4D87lYeYLDRVkACCAUtkFIXVgyJL-EIFiidYFDaEgyzCIOSJCP8DB+CiJJVmF3BZSUQgsDYlCfEIFCwZJDDUmAlVPG1YCHMwonld1LGpTVPBLEEuC4H5pVAWkTANcEqGlSVuDCBwtBru0AAq+pCAAEgA8gA6jtR1CMiuAkDAFDZbgQhgAw+kxA1MAMEEKAOcs3VCAgNC1llnFPAgXA-XZW1TshcWuQAzHYHaRfDU5ZnFxRuAgpD9fFy5ECUiiw5eurmNoFBo9s06CNt2zfu4GInNNPgfMiMiiCIYjeLo0SIe0GjXs+96NsR9y5uutO1PTCDTXEdgWGQ0bAN4zOyHEGGCPKRCtbg+HAKqPNkD8pPk2+mMkGA6ES9oMNgPDTbJe2ghIzDqO6j+pvY7j+OE-rZhG8TOx222M7+80dPsAzD1K0ishsxzXNaZpvPbPzxHzgLIsh8CEvh1LuAy3LCtRyzqu-IFDsMBrWs63ricU7UfvribWMWy76iZDhmQcPhQrC0gpFBhQ2K4kskqMe07HCtMqqKaPeaONp6yYEAA))

In Parent component, you define a listener that fires actual event with correct context.
For example, in `component-dropdown` template (which uses `dropdown` under the hood):

```pug
span ComponentDropdown:
dropdown(
    "{{#if @context.hasListener('select')}}on-select='_select'{{/if}}"
    ...
)
```
and manually define `_select` listener like so:

```ls
...
on:
    _select: (ctx, ...args) ->
        c = ctx.getParent(true); c.refire = true;
        @fire \select, c, ...args
```
