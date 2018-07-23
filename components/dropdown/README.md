# Data format

```ls
[
    {id: "foo", name: "The Foo", some: "other", keys:"are", also:"possible"},
    ...
]
```

If your format is different from `id` and `name`, pass these names with `key=` and `name=` attributes
respectively.

## Basic Usage

```pug
dropdown(
    data="{{data}}"
    selected-key="{{mydata}}"
    item="{{item}}")
```

## Custom Template

Use `custom` attribute and `custom` partial to define a custom template to dropdown.

```pug
dropdown(
    custom
    data="{{data}}"
    selected-key="{{mydata}}"
    item="{{item}}")
    +partial('custom')

        //- Available Ractive variables:
        //-     loading, error, data, dataReduced, keyField, nameField
        //-     debug, block

        .ui.dropdown(
            input(type="hidden" name="filters")
            i.dropdown.icon
            span.text -------
            .menu
                .ui.icon.search.input
                    icon.search
                    input(type="text" placeholder="Search...")
                .scrolling.menu
                    +each('dataReduced')
                        .item(
                            data-value!="{{.id}}"
                            data-text!="{{.name}}")
                            span.text {{.name}}
                            span.description {{.description}}
```


## Async usage

```pug
dropdown(
    data="{{data}}"
    selected-key="{{mySelected}}"  # <-- this is read-only in this mode
    on-select="itemSelected"
    )

```

```ls
itemSelected: (ctx, item, progress) ->
    # item format: original data format
   ...do your async job here

    # if `progress` function is called without error, `item=` and
    # `selected-key=` attributes are set accordingly. if `progress` is
    # called with a truthy value, selection is restored to the previous
    # state.
    progress!
```

## Blacklisting

Use `blacklist=` attribute to disable any option dynamically.

## Visual Options

For inline or fluid instances, use `inline` or `block` attributes respectively.

## Multiple Selection

```pug
dropdown(
    multiple
    selected-key="{{someProperty}}"  <- "someProperty" is treated as an array
    ...
)
```

## Allow Addition

In this mode, a `+ the search term` button is shown when something is typed in the
search area.

```pug
dropdown(
    on-add="someHandler"
)
```

```ls
someHandler: (ctx, newKey, proceed) ->
    # newKey is the search term
    btn = ctx.button  # ack-button instance
    ...
    proceed err=yes/no
```

### Custom Add Button

Define a `addNew` partial under the `dropdown` which fires `_add` handler to add:

```pug
dropdown(
    ...
    on-add="someHandler"
    )
    +partial('addNew')
        .ui.button(on-click="_add") ADD THIS: {{~/['search-term']}}
```

## Debugging

When you need to debug anything, just pass the `debug` attribute:

```pug
dropdown(
    ...
    debug)
```

## "Loading" state

To control the `loading` state:

```pug
dropdown(
    loading="{{loadingState}}"
    ...
)
```

If you only start with loading state:

```pug
dropdown(
    start-with-loading="true"
    ...
)

Note: `loadingState` is set to `false` by the `dropdown` when `dropdown`'s data
is changed and not empty.
