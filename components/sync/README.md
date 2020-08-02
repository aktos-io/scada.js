# Description

Synchronizes `value` with `route`. Attributes:

* route: topic to keep in sync
* value: value of `sync-topic`
* readonly: do not send changes
* on-error: callback(ctx, error)
* on-read: callback(ctx, value)
