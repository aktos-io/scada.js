require! express
require! 'body-parser': body-parser
require! {
    '../lib/aea': {
        pack, unpack, sleep
        wait-for, go, is-waiting
        debug-log
    }
}

app = express!


device-public = "#{__dirname}/../../build/device-public"
app.use express.static device-public
app.use body-parser.urlencoded {+extended}
app.use body-parser.json!

msg-box =
    'abc123': []

app.post '/send' (req, res) ->
    payload = req.body
    node = payload.node

    try
        throw 'id too short' if node.length < 3
    catch
        debug-log "Error: #{e}"
        return

    debug-log "node: ", node, "data: ", payload.data
    if is-waiting node
        #debug-log "node: #{node} was waiting, releasing!!!"
        go node
    req.on \close, ->
        debug-log "peer closed connection, releasing!"
        go node
    debug-log "Waiting for any server side events..."
    <- wait-for node
    try
        data = msg-box[node].shift!
        debug-log "Pushing data to the client: " if data
        res.send data

i = 0
do function simulate-server-events
    return
    <- :lo(op) ->
        debug-log "Generating server side event!"
        msg-box[\abc123] ++= ["naber#{i++}\n"]
        go \abc123
        <- sleep 10000ms
        lo(op)


#app.get '/receive', (req, res) ->
#    debug-log "receive: ", req, res

<- app.listen 5656
console.log "Server started on *:5656"
