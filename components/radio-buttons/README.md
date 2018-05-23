# Content can be used as value

```pug
radio-buttons(value="{{myvariable}}")
    radio-button(default) Hello
    radio-button World
```

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
