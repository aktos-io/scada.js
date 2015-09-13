# Creating a widget

1. choose a `widget-name` with lowercase and separated with a dash ('-') if multiword and create a folder with the same name

        mkdir your-widget

2. run `./update-partial-includes.sh` to refresh `ractive-partials.ls` and `ractive-partials.jade`
3. Edit your files' contents accordingly. 


# Naming Conventions 

1. Parent CSS class in HTML SHOULD use the same `widget-name`

        <div class="your-widget ...
    
2. Consequently, your jQuery loop SHOULD use the same `widget-name`

        RactivePartial! .register[-for-document-ready] ->
          $ \your-widget .each -> 
            # initialize your widget 
            ...
      
