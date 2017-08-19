do ->
    old = console.log
    logger = document.getElementById \debugDiv
    console.log = ->
        old.apply console, arguments
        try
            for arg in arguments
                logger.innerHTML += if typeof! arg is \Object
                    if JSON and JSON.strigify
                        JSON.stringify arg, undefined, 2
                    else
                        "Something we can not convert with JSON.stringify"
                else
                    "#{arg}<br />"
