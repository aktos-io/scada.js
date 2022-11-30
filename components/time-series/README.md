# Data Format

`data=` format is like `[Array of {x, y}]` where `x` is the Unix timestamp
in milliseconds.

# Usage

Simple time series:

```pug
time-series(
    name="Tank Level"             <--- Required for hover text
    y-format="#.## m3"            <--- Required for hover text
    data="{{levelGraphData}}"     <--- Required, Array of {x, y} Object
    y-max="{{max}}"               <--- Optional: Hardcoded max value for Y-axis, default: dynamic (max in data)
    y-min="{{min}}"               <--- Optional: Hardcoded min value for Y-axis, default: 0
    y-width="10"                  <--- Optional: Y-axis width
)
```

# Known Problems 

This component is not fully responsive. It's width is calculated only on the first load.