require! express
require! 'body-parser': body-parser
require! {
    '../../lib/aea': {
        pack, unpack, sleep
        wait-for, go, is-waiting
        debug-log
    }
}
fs = require \fs
app = express!


device-public = "#{__dirname}/../../build/device-public"
app.use express.static device-public
app.use body-parser.urlencoded {+extended}
app.use body-parser.json!

msg-box =
    'abc123': []
k = 0

app.get '/todo/_changes' (req, res) ->
    console.log "got client request params: ", req.params
    console.log "got client request query: ", req.query
    req.on \close, (...x) ->
        console.log "Closed connection? ", x
        
    <- sleep 5000ms
    console.log "/_changes simulate feed..."
    res.send {ack: "simulating feed..."}

app.get '/' (req, res) ->
    console.log "info got client request query: ", req.query
    res.send {aktos: \Welcome, info: "aea device server", version: "0.7"}

app.put '/todo/:id' (req, res) ->
    payload = req.body
    node = payload.node
    doc_id = req.params.id
    debug-log "PUT::: node: ", node, pack payload, req.params.id
    debug-log "PUT doc_id: ", doc_id
    res.send {ack: "OK"}

/*
app.post '/test' (req, res) ->
    payload = req.body
    node = payload.node
    try
        throw 'id too short' if node.length < 3
    catch
        debug-log "Error: #{e}"
        return

    debug-log "SEND SIDE::: node: ", node, "data: ", pack payload.data
    res.send {ack: "OK"}
*/
/*
app.post '/al' (req, res) ->
    payload = req.body
    node = payload.node
    console.log "Payload: ", payload
    console.log "WELCOME."
    <- sleep 5000ms
    #Read the code file
    fs.read-file \send-file.js, (err, data) ->
        if err
            throw err
        console.log "Sending this: ", pack data.to-string!
        #res.send do
        #    code: pack data.to-string!
        #res.send {code: pack ("a" * 51)}
        #res.send-file '/home/mesut/dev/demeter-scada2/src/server/send-file.js'
*/
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
