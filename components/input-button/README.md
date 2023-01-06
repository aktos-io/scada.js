# input-button

This component displays content inside it, after applying the `class`.

Recommended: Use `class="ui label"` for most of the cases. 

When the button is clicked, a popup is opened in order to change the 
value that is assigned by the `value=` attribute. 

# Example

```pug
    input-button.teal(
        value="{{value}}"   <-- Value to be manipulated
        style=""            <-- Style of display element, use {{#error}}outline: 1px dashed red;{{/}} for error indication. 
        class="ui label"    <-- Class of display element
        error=              <-- Sets the input element as "disabled" inside the popup
        title=              <-- Title of the popup
        readonly=           <-- Only display the "{{.text}}", do not open the popup on click
        
        ) {{.text}}
```