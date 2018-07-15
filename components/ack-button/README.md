# Enabled/disabled State

```pug
ack-button.green(
    on-click="setJobState"
    cmd="job-state"
    enabled="{{.state === 'approved'}}"
    action="finished") Production Finished
```
