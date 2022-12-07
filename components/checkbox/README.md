# Simple, sync usage

```pug
checkbox(checked="{{mybool}}") My Checkbox
```


# Async usage

```pug
checkbox(
    checked="{{mybool}}"  # <- is set only if myhandler returns with success
    async on-statechange="myhandler") My Checkbox
```

```ls
myhandler = (ctx, new-state, proceed) ->
    /* do something here */
    proceed err=null
    # if error isnt null, then checkbox state will be restored
    # to the previous value.
```

# Other attributes

`mark-value="123"`: Set this value when the checkbox is in `checked` state.
`clear-value="0"`: Set this value when the checkbox is in `unchecked` state.
