# Properties


Marks last clicked row
Display a message while opening a row
Displays error or info messages
Opens appropriate row if url matches with document id
Scrolls to clicked row (or opening row by url)
Disables other rows in order to prevent accidental openings while a row is opened
Displays a warning if a filter is selected other than `all`

# Names

tableview : whole array that has the minimum data to create table view

tableview_visible: only the items for the current (selected) page of `tableview`

curr: current document that is selected or being created

readonly: if data-table has no `editForm` partial or set `readonly` explicitly, then it is readonly

# Partials (sections)

header: Head section of data table

viewForm: The section that appears when a row is clicked

editForm: The section that appears when something "Edit" button is pressed


# Behaviour

`data-table` won't display any new entries unless it's successfully written to the database.

`curr` document will be fetched from database everytime

if `auto-refresh` is not set to `yes`, a `Click to update` button will popup when table data is
modified outside current window.
