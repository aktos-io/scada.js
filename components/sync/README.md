# Description

Synchronizes `curr` with `sync-topic`. Attributes:

* sync-topic: topic to keep in sync
* curr: value of `sync-topic`
* readonly: do not send changes
* on-error: callback(ctx, error)
* on-read: callback(ctx, value)
