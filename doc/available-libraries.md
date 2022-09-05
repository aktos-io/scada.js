# Description

This is the documentation of available methods and classes by default in ScadaJS.



# lib/aea/defaults.ls

See lib/aea/defaults.ls



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

## Yes/No and full screen info

See comment sections of `vlogger.ls` file.

## Pnotify

Example:

```ls
mypopup = PNotify.alert do
    type: \error
    title: "Foo is Updated"
    text: """
        Something happened ... bla bla
        """
    hide: no
    modules:
        Buttons:
            closer: yes


# If you want to close the popup programmatically:
mypopup.close!
```

# Modal 

See Ractive Modal: https://kouts.github.io/ractive-modal/demo/

## Request Library

SuperAgent is bundled with ScadaJS by default: https://github.com/visionmedia/superagent
