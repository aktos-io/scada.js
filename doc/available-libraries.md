# Description

This is the documentation of available methods and classes by default in ScadaJS.

# Methods/functions


# `parseCsv()`

```ls
require! 'aea/csv-utils': {parse-csv}

err, csv <~ parse-csv content, {columns: "material,amount,reason"}
unless err
    for row in csv.rows
        console.log row.material, row.amount, row.reason

```

# Visual Logger

## Initialization

logger = new VLogger this, "My Source"

## Yes/No Question

```ls
answer <~ logger.yesno do
    title: "Discard changes?"
    message: "If you select 'Drop Changes' all changes will be lost."
    buttons:
        drop:
            color: \red
            text: 'Drop Changes'
            icon: \trash

        cancel:
            color: \green
            text: 'Cancel'
            icon: \undo

if answer is \drop
    # do something
else
    logger.cwarn "Cancelled discarding changes."
```

## Pnotify

Example:

```ls
PNotify.alert do
    type: \error
    title: "Foo is Updated"
    text: """
        Something happened ... bla bla
        """
    hide: no
    modules:
        Buttons:
            closer: yes
```

# Modal 

See Ractive Modal: https://kouts.github.io/ractive-modal/demo/

## Request Library

SuperAgent is bundled with ScadaJS by default: https://github.com/visionmedia/superagent
