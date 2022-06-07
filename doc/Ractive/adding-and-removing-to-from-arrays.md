# Adding and removing to/from arrays


```pug
r-table.striped
    r-head
        r-head-col foo
        r-head-col bar
        r-head-col baz
    r-body
        +each('.values')
            r-row
                r-col {{@index}}
                r-col 
                    //- This button will remove current element from the `./values` array. 
                    //- `@context.removeMe()` is defined in scada.js/vendor2/01.ractive-npm/z_ractive_extras.ls
                    .ui.button.icon.basic.red(on-click="@context.removeMe()") 
                        icon.trash Remove current

    r-foot
        r-row
            r-col 
                //- This button will add an empty array to `./values` field. 
                btn.icon.basic.green(on-click="@context.push('.values', [])"): icon.plus Add
```