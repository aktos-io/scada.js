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

    
