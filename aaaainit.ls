require! Wifi:wifi
{sleep, config, Led, pack, unpack, repl} = require \aea

main-page = "<html><head>\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"></head><body>\n<div id=\"console\" style=\"width:100%;height:100%;overflow:auto;\">Type in the text box below...<br/></div>\n<textarea id=\"jscode\" style=\"position:absolute;left:0px;bottom:0px;width:100%;\"></textarea>\n<script>\n  document.getElementById(\"jscode\").onkeypress = function(k) {    \n    if (k.keyCode == 13) { // newline\n      k.preventDefault();\n      var e = document.getElementById(\"jscode\");\n      var cmd = e.value;    \n      e.value = \"\";\n      var c = document.getElementById(\"console\");\n      c.innerHTML += \"&gt;\"+cmd+\"<br//>\";\n      console.log(\"Sending command \"+cmd);\n\n      var xmlhttp=new XMLHttpRequest();\n      xmlhttp.onload = function() {      \n        console.log(\"Got response \"+this.responseText);\n        c.innerHTML += \"=\"+this.responseText+\"<br//>\";\n      };\n      xmlhttp.open(\"GET\",\"/cmd?eval=\"+cmd,false);\n      xmlhttp.send();\n    } else if (k.keyCode == 10) { // Ctrl+enter\n      k.preventDefault();\n      document.getElementById(\"jscode\").value+=\"\\n\";\n    }\n  }\n</script>\n</body></html>\n"

on-page = (req, res) ->
    rurl = url.parse req.url, true
    if rurl.pathname is "/"
        res.write-head 200, do
            'Content-Type': 'text/html'
        res.end main-page
    else if rurl.pathname is "/cmd"
        res.write-head 200, do
            'Content-Type': 'text/plain'
    value = ""
    console.log rurl
    if rurl.query and rurl.query.eval
        value = eval rurl.query.eval
        res.end value
    else
        res.write-head 404, do
            'Content-Type': 'text/plain'
        res.end "Not Found."


connect-to-wifi = !->
    do
        <- :lo(op) ->
            try
                wifi-setting = config.read setting.wifi
                essid = wifi-setting.essid
                throw if essid is void
                passwd = wifi-setting.passwd
                health = wifi-setting.health  # if health is 0 then wifi network is dead
            catch
                # connect to default essid
                essid = \aea
                passwd = \084DA789BF
                health = -1  # last resort
                console.log "Using default ESSID: ", essid

            #led-connected.att-blink!
            <- :lo(op) ->
                apn <- wifi.scan
                for i in apn
                    console.log "Found ESSID: ", i.ssid
                    if i.ssid is essid
                        #led-connected.blink!
                        return op!
                console.log "ESSID '{#{essid}}' not found, searching again..."
                <- sleep 2000ms
                lo(op)

            <- :lo(op) ->
                console.log "trying to connect to wifi..."
                err <-! wifi.connect essid, {password: passwd}
                console.log "connected? err=", err, "info", wifi.getIP!
                if err is null
                    try
                        #console.log "trying connecting to server..."
                        #try-connecting-server!
                        return op!
                    catch
                        console.log "WTF:", e
                <- sleep 5000ms
                lo(op)


on-init = !->
    connect-to-wifi!
    <- sleep 5000ms
    console.log "Here is starting.."
    require \http .createServer on-page .listen 80
