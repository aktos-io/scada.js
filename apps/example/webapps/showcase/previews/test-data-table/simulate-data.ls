colors =
    \red
    \pink
    \olive
    \teal
    \blue
    \purple

lorem = (arg) -> """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Vestibulum ...... #{arg} ..... vitae velit ac lacus consequat
    posuere at id erat. Pellentesque sit amet rhoncus ipsum, a lacinia ipsum.
    """

export simulated-data = [{
    _id: "#{..}"
    type: \test
    timestamp: .. * 100
    color: colors[Math.floor(Math.random()*colors.length)]
    name: lorem ..
    } for [1 to 10]]

# Example settings
export simulated-timeouts =
    first-loading-time: 2000ms
    row-opening-time: 2000ms
