# Basic Usage 

```pug
ack-button(
    on-click="myHandler"
    my-param="hello") Hello!

```

```ls
on:
    myHandler: (ctx) -> 
        btn = ctx?component 
        return unless btn

        btn.state \doing # Set button state to "doing"
        #... 
        # if async work will take a long time, you can indicate the 
        # process is not stalled by sending "heartbeat"
        <~ sleep 1000ms 
        btn.heartbeat!
        <~ sleep 1000ms 
        btn.state \done
        my-param = btn.get 'my-param'
        err, res <~ btn.actor.send-request "@foo.bar", {my: my-param}
        if err 
            btn.state \error 
        else 
            btn.state \done
```

On the other side:

```ls 
new class Foo extends Actor
    action: ->
        @on-topic \@foo.bar, (msg) ~>
            console.log "foo.bar message received, my-param is:", msg.data.my
            @send-response msg, {hey: \there}
```


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
