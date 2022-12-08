# input-button

This component displays a button and yields the content inside it. 

When the button is clicked, a popup is opened in order to change the 
value that is assigned by the `value=` attribute. 

# Example

```pug
    input-button.teal(
        value="{{value}}" 
        style="{{#error}}outline: 1px dashed red;{{/}}"     <-- style of display element
        class=                                              <-- class of display element
        inline=                                             <-- optional, boolean
        error=                                              <-- block changing the input
        
        ) {{.text}}
```