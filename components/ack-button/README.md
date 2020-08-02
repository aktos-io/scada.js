# Enabled/disabled State

```pug
ack-button.green(
    on-click="setJobState"
    cmd="job-state"
    enabled="{{.state === 'approved'}}"
    action="finished") Production Finished
```


### Send request, handle response

```ls
btn = ctx?component
btn?state \doing
# do async work here.
#btn?heartbeat!
if err => btn?error "Some error message"
btn?state \done...
@logger.clog "changes done..."
```
