colors =
    \red
    \pink
    \olive
    \teal
    \blue
    \purple

export simulated-data = [{
    _id: "#{..}"
    type: \test
    timestamp: .. * 100
    color: colors[Math.floor(Math.random()*colors.length)]
    name: "this is #{..} and this line is very log as you can easily understand"
    } for [1 to 10]]

# Example settings
export simulated-timeouts =
    first-loading-time: 2000ms
    row-opening-time: 2000ms
