# Data Format

`data=` format is like `[{key: .., value: ..}, ...]` where the `key` is Unix timestamp
in milliseconds.

# Usage

Simple time series:

```pug
time-series(
    data="{{levelGraphData}}"     <--- Required
    y-format="#.## m3"            <--- Required
    name="Tank Level"
    data-limit="100"              <--- Enabled by default. Use -1 to disable.
```


# Live Graph

Set `live="true"` and Add new data by `current=` attribute:

```pug
time-series(
    ...
    current="{{myNewValue}}"
    live="true"
)
```
