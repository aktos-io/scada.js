add-script = (script-data) ->
    newdiv = document.createElement \div
    script = document.createElement \script
    script.innerHTML = script-data
    newdiv.appendChild script

    try
        document.getElementById \dynamic-script .appendChild newdiv
    catch
        console.warn "This is a workaround in templates/load-app.ls because window.onload is not firing in electron."


$.ajax do
    url: \app.js
    type: \GET
    success: (data) ->
        console.log "page loaded. data length: ", data.length
        addScript data

    error: (e) ->
        msg = "something went wrong while loading page: "
        console.log msg, e
        $ '#loading-error' .show!

    xhr: ->
        $ '#percentProgress' .progress {showActivity: false}
        $ '#loading-error' .hide!

        xhr = new window.XMLHttpRequest!


        # upload progress
        xhr.upload.addEventListener \progress, ((ev) ->
            if ev.lengthComputable
                percentComplete = ev.loaded / ev.total
                console.log "Upload complete % #{percentComplete * 100}"

            ), false

        # download progress
        xhr.addEventListener \progress, ((ev) ->
            if ev.lengthComputable
                percentComplete = ev.loaded / ev.total
                percentInt = parseInt(percentComplete * 100)
                #console.log "Download complete % #{percentComplete * 100}"
                $('#percent').text(percentInt);
                $('#percentProgress').progress("set progress", percentInt);
            ), false
        xhr
