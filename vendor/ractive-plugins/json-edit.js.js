function fixJSON(badJSON){
    //taken from https://stackoverflow.com/a/39050609/1952991 (Malvineous)
    return badJSON

    // Replace ":" with "@colon@" if it's between double-quotes
    .replace(/:\s*"([^"]*)"/g, function(match, p1) {
        return ': "' + p1.replace(/:/g, '@colon@') + '"';
    })

    // Replace ":" with "@colon@" if it's between single-quotes
    .replace(/:\s*'([^']*)'/g, function(match, p1) {
        return ': "' + p1.replace(/:/g, '@colon@') + '"';
    })

    // Add double-quotes around any tokens before the remaining ":"
    //.replace(/([^'"])([A-zÀ-ÿ0-9_]+)(['"])\s*:/g, '"$2": ')
    //https://regexr.com/3mgc3
    .replace(/\s*([^'",])([A-zÀ-úçışöğüÇİŞÖĞÜ0-9_\s]*[A-zÀ-úçışöğüÇİŞÖĞÜ0-9_]*)([^'"\s])\s*:/g, '"$1$2$3": ')

    // Turn "@colon@" back into ":"
    .replace(/@colon@/g, ':')
;
}

Ractive.components['json-edit'] = Ractive.extend({
  template: `<textarea style="white-space: pre-wrap; border: 1px {{#if err}}dashed red{{else}}solid green{{/if}}" title="{{err}}">{{ objFormatted }}</textarea>`,
  isolated: true,
  data: function(){
    return {
        objTmp: undefined,
        value: undefined,
        err: null
    }
  },
  computed: {
    objFormatted: {
      get: function(){
        var that;
        if (that = this.get('objTmp')) {
          return that;
        } else {
          return JSON.stringify(this.get('value'), null, 2);
        }
      },
      set: function(objStr){
        var obj, e;
        try {
          obj = JSON.parse(fixJSON(objStr));
          this.set('value', obj);
          this.set('objTmp', null);
          this.set('err', null);
          return
        } catch (e$) {
          e = e$;
          console.log("error was: ", e, fixJSON(objStr));
          this.set('err', e);
          return this.set('objTmp', objStr);
        }
      }
    }
  }
});
/*
new Ractive({
	el: 'body',
	template: `
		<h2>Input</h2>
		<p>Type a JSON here: </p>
		<json-edit value="{{foo}}" />
		<h2>Output:</h2>
		<pre>{{JSON.stringify(foo)}}</pre>
	`,
	onrender: function(){
		this.observe('foo', function(value){
			console.log("foo is changed", value)
		})
	}
})
*/
