# Creating a widget

1. choose a `widget-name` with lowercase and separated with a dash ('-') if multiword and create a folder with the same name

        mkdir your-widget

2. run `./update-partial-includes.sh` to refresh `ractive-partials.ls` and `ractive-partials.jade`
3. Edit your files' contents accordingly. 
4. Test your widget. 

# Testing Widget

1. Place your widget into `scada-drawing-area`, as in the `demos-showcase.jade` page. 
2. Your widget SHOULD be resizable. 
3. Your widget SHOULD be draggable. 


# Naming Conventions 

1. Parent CSS class in HTML SHOULD use the same `widget-name`

        <div class="your-widget ...
    
2. Consequently, your jQuery loop SHOULD use the same `widget-name`

        RactivePartial! .register[-for-document-ready] ->
          $ \your-widget .each -> 
            # initialize your widget 
            ...
      
