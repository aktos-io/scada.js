function pushSafe({proto}) {
	proto.push2 = function (keypath, value, ...rest) {
		if(!this.get(keypath)){
			this.set(keypath, [])
		}
		return this.push(keypath, value, ...rest);
	}
}
Ractive.use(pushSafe);

/*
new Ractive({
	el: 'body',
	template: `
		<h2>Input</h2>
		<button on-click="@.push('foo.bar', {hello: 'world'})">push!</button>
		<button on-click="@.push2('foo.bar', {hello: 'world'})">push2!</button>
		<pre>{{JSON.stringify(foo)}}</pre>
	`,
	data: {
		count: 0,
		foo: {
			bar: null
		}
	}
})
*/
