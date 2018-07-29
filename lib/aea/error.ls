htmlEncode = (html) ->
    return html
        |> $.trim
        |> (x) -> x.replace /[&"'\<\>]/g, (c) ->
            switch c
            | '&' => "&amp;"
            | "'" => "&#39;"
            | '"' => "&quot;"
            | "<" => "&lt;"
            |_ => "&gt;"

window.loadingError = (err) ->
    container-name = "scadaErrorSection"
    if err
        try
            document.getElementById 'content'
                ..style.display = \none

        container = document.createElement \div
            ..class-name = container-name
            ..style
                ..position = \fixed
                ..top = \0px
                ..width = \100%
                ..overflow = \auto

        document.getElementsByTagName \body .0.appendChild container

        message = document.createElement \div
            ..class-name = "ui red message"
            ..innerHTML = "<h1>ERROR</h1>"
            ..innerHTML = "<pre>#{htmlEncode err}</pre>"

        container.appendChild message
    else
        # remove the error divs
        containers = document.getElementsByClassName container-name
        while containers.0
            containers[0].parentNode.removeChild(containers[0])
