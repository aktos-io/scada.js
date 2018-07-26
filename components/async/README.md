# Asynchronous Component Placeholder

You can block rendering of a component untill the component is fetched from
its source.

There are 3 flags that cause the component to be rendered:

- `@shared.deps[name]` variable (where `name` should be the component name)
- `@shared.deps._all` variable which indicates that "All components are fetched"
- `ready=` attribute
