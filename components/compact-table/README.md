Table headers are rotated 45 degree, so very small cells can be
displayed in a very compact form.

Usage:

```pug
table.compact-table
    thead
        tr
            th.rotate: div: span foo
            th.rotate: div: span bar

    tbody
        tr
            td foo value
            td bar value
        ...
```
