# ASYNC components' synchronizers
# Require ./heavy-components in somewhere
require! './ace-editor/sync'
require! './time-series/sync'
require! './ddoc-editor/sync'

# relatively heavy components (TODO: CLEANUP THEM)
# -----------------------
require! './aktos-dcs'
require! './checkbox'
require! './ack-button'
require! './led'
require! './print-button'


# lightweight components by sizes
# -------------------------------
require! './async'
require! './overlap'
require! './io-label'
require! './seven-segment'
require! './drawing-area'
require! './cache-asset'
require! './activity'
require! './terminal'
require! './pushbutton'
require! './scroll-x'
require! './browser-storage'
require! './formatter'
require! './vertical-divider'
require! './radio-buttons'
require! './p'
require! './assign'
require! './checklist-button'
require! './checklist'
require! './coll-panel'
require! './data-table'
require! './date-picker'
require! './db-img'
require! './debug-obj'
require! './json-edit'
require! './example-component'
require! './export-to-csv'
require! './file-button'
require! './formal-field'
require! './key-value-grid'
require! './router'
require! './r-table'
require! './input-field'
require! './dropdown'
require! './logger'
require! './todo'
require! './ui-progress'
require! './progress'
require! './slider'
require! './login'
require! './icon'
require! './btn'
require! './s-input'
require! './accordion'
require! './rich-text'


# decorators
require! './decorators/tooltip'
require! './decorators/semantic-ui/popup'
require! './decorators/semantic-ui/inline-popup'
require! './decorators/semantic-ui/accordion'
require! './decorators/semantic-ui/dropdown'
require! './decorators/semantic-ui/sidebar'
