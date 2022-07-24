# Data format

Use `data=` attribute to pass the data source to the dropdown. Data format is as follows:

```ls
[
    {id: "foo", name: "The Foo",
        some: "other", keys:"are", also:"possible"},
    ...
]

```


If your format is different from `id` and `name`, pass these names with `key=` and `name=` attributes
respectively.

### Using simple array:

Use `simple-data=` attribute to pass simple array input, like: `['foo', 'bar', ...]`

### Using Object:

Use `object-data=` attribute to pass a simple object input, like:

```
{
    foo: 'bar'
    hello: 'there'
}
```

`data=` is generated internally by `[{id: k, name: k, content: v} for k, v of object-data]`.

## Basic Usage

`data`: Explained above
`selected-key`: Selected item's key (`id` by default).
`item`: Selected item as a whole object.

```pug
dropdown(
    data="{{data}}"
    selected-key="{{mydata}}"
    item="{{item}}")
```

## Custom Template

Pass `custom` partial to define a custom template to dropdown.

```pug
dropdown(
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
    on-select="itemSelected"       # <-- when "on-select" event used,
    selected-key="{{mySelected}}"  # "selected-key" becomes read-only
    )

```

#### Handler

```ls
itemSelected: (ctx, item, progress) ->
    #...do your async job here
    progress error-status
```

* `item` :
    * Original data (array item) if `selected-key=` is found in `data=`
    * An empty array (`{}`) if no match is found (useful for cleanup tasks)

* `progress`: Error handler
    - Success if called with a `falsey` value
    - Error if called with `truthy` value: Selection is restored to previous state
        - If `error-status` is string, a modal is displayed containing the message.

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

In this mode, a `[+] the search term` button is shown when something is typed in the
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

# Variants

```pug
dropdown(... button)

dropdown(... compact)
```
