# Content can be used as value

```pug
radio-buttons(value="{{myvariable}}")
    radio-button(default) Hello
    radio-button World
```

Note: In order to unite the buttons, encapsulate them by a `.ui.buttons` div.

# Typical Usage

```pug
radio-buttons(value="{{transfer.state}}")
    .ui.buttons
        radio-button.icon(
            value="pending"
            default                     # <- optional, set default value if null
            true-color="yellow")        # <- optional, set selected color per button
            icon.minus.square                            
        radio-button.icon(
            value="accepted"
            true-color="green")         # <- optional, set selected color per button
            icon.check.square
```

# Async mode

```pug
radio-buttons(
    value="{{myvariable}}"
    on-select="myHandler")
    radio-button(default) Hello
    radio-button World
```


```ls
myHandler: (ctx, new-val, proceed) ->
    # new-val is currently clicked value.
    # When `proceed`ed without error, radio button switches its state
    if some-error
        # radio button won't switch its state
        return proceed "some error occured"
    proceed!
```

# Enabled/disabled state

Use `value` variable to decide the `radio-buttons`' state.

```pug
radio-buttons(
    value="{{myvariable}}")
    radio-button(
        enabled="{{value === 'foo'}}"
        ) Hello
    radio-button World
