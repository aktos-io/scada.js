Taken from: http://mcgivery.com/htmlelement-pseudostyle-settingmodifying-before-and-after-in-javascript/

# Example 1: Modify

Say we have these styles:

    .test:before		{
	    content: "testing";
	    color: red;
    }

And this HTML:

    <div id="testDiv" class="test">test2</div>
In this example, we have an element which already has a :before with styles set. Here is how we would modify them:

    var div = document.getElementById("testDiv");
    div.pseudoStyle("before","color","purple");

See It in Action: http://jsfiddle.net/Tf69a/

# Example 2: Set
Say we have an element with NO :before styles currently set:

    <div id="testDiv">test2</div>

Here’s how we would set some :before styles:

    var div = document.getElementById("testDiv");
    div.pseudoStyle("before","content","'test'");
    div.pseudoStyle("before","color","purple");

OR we can chain methods:

    var div = document.getElementById("testDiv");
    div.pseudoStyle("before","content","'test'").pseudoStyle("before","color","purple");

See it in action: http://jsfiddle.net/Tf69a/1/

