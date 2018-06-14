# Description

This is the documentation of available methods and classes by default in ScadaJS.

# Methods/functions

### `able()`

Available in: template, code.

Description: Checks if current user has this permission.

Types:

* `permission`: Topic type.
    
Usage: 

    {{#if able('some.permission')}}
        has this permission 
    {{else}}
        don't have this permission
    {{/if}}

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

## Request Library 

SuperAgent is bundled with ScadaJS by default: https://github.com/visionmedia/superagent

