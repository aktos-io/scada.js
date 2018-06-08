# Data format

```
{id, name}
```

If your format is different, pass these names with `key=` and `name=` attributes
respectively.

## Basic Usage

```
dropdown(
    data="{{data}}"
    selected-key="{{mydata}}"
    item="{{item}}")
```

## Custom Template

Use `custom` attribute and `custom` partial to define a custom template to dropdown.

```
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
    selected-key="{{mySelected}}"  # <-- this is read-only
    async on-select="itemSelected"
    )

```

```ls
itemSelected: (ctx, item[, progress]) ->
    # item format: original data format
    # ...
    # do your async job
    if not err
        @set mySelected, item.id  # or any attribute available in `item`

    # if `progress` function is called without error, `item=` attribute is set
    # accordingly
    #progress!
```

## Blacklisting

Use `blacklist=` attribute to disable any option dynamically.

## Visual Options

For inline or fluid instances, use `inline` or `block` attributes respectively.

## Multiple Selection

```pug
dropdown(
    multiple
    selected-key="{{someProperty}}"  <- array
    ...
)
```

## Allow Addition

```pug
dropdown(
    allow-addition on-add="someHandler"
)
```

```ls
someHandler: (ctx, newKey) ->
    ...
```
