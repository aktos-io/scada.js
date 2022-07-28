# Example

See https://aktos.io/st/#/showcase/data-table

# Properties

- Provides `on-init = (cb) -> cb!` function for initialization.
- Executes a function while opening a row (`on-create-view = (row, cb) -> return cb(err, curr)` or `(row) ->> return curr`. `row` is the relevant element of `tableview` array.)
- Displays error or info messages
- Opens appropriate row if url matches with document id
- Scrolls to clicked row (or opening row by url)
- Memorizes last clicked row (`isLastClicked(.id)`)
- Disables other rows in order to prevent accidental openings while a row is opened
- Displays a warning if a filter is selected other than `all`

# Variables

`tableview` : Whole array that has the minimum data to create table view

`tableview_visible`: only the items for the current (selected) page of `tableview`

`curr`: current document that is selected or being created

`readonly`: if data-table has no `editForm` partial or set `readonly` explicitly, then it is readonly

`print_mode`: (Bool) Indicates that current view form is in print mode.

`tmp`: (Object) A temporary variable that resets on every view-form creation.

`this.actor`: Data-table's actor.

# Partials (sections)

header: Head section of data table

viewForm: The section that appears when a row is clicked

editForm: The section that appears when something "Edit" button is pressed


# Behaviour

`data-table` won't display any new entries unless it's successfully written to the database.

`curr` document must be manually assigned within `on-create-view` handler.

if `auto-refresh` is not set to `yes`, a `Click to update` button will popup when table data is modified outside current window.

Fields declared in `search-field` must be maximum of 2 levels deep (`value.foo_bar` is okay but `value.foo.bar` is not okay).

# Mark last clicked row 

Use `isLastClicked(rowId)`: 

    .ui.basic.label(
        on-click="openRow" 
        class="{{#if isLastClicked(.id)}}orange{{/if}}") {{.id}}

# Full screen 

Any opened row may be displayed as full screen for printing purposes. To make a row go full screen, 

1. Design your edit/view form with `{{print_mode}}` (`true`/`false`) variable to hide elements in print mode. 
2. Use `fire('make_row_full_screen')` and `fire('make_row_normal')` events to go to and return from full page.
3. `@global.fullScreen` variable is set to true while in full page. Use this variable to hide the main menu. Tip: 

    ```pug
    .pusher(style="{{#if @global.fullScreen}}display: inline;{{/if}}")
        ...
    ```