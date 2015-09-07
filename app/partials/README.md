# Creating a widget

Easiest way to create a widget is copy and modify a current one.
Then you need to do the followings: 

* create a widget with the following layout: 

  * index.ls (or index.js) : contains javascript for the widget
  * widget.jade : contains widget html
  * widget.css: contains widget style

* register livescript/javascript code in ractive-partials.ls

    require './textbox'

* register jade code in ractive-partials.jade

    include ./textbox/widget.jade

    
# Naming Conventions

* choose a widget name with lowercase and separated with a dash ('-') if multiword.

    your-widget
    
* folder name of the partial SHOULD use the same widget name

    partials/your-widget/...
    
* Parent CSS class in HTML SHOULD use the same widget name

    <div class="your-widget ...
    
* Consequently, your jQuery loop SHOULD use the same name

    $ \your-widget .each -> 
      # initialize your widget 
      ...
      
