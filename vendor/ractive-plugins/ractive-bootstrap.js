/* Buttons */

Ractive.components['btn'] = Ractive.extend({
	isolated: true,
	data: {
		type: 'default',
		value: '',
		class: '',
		style: '',
		disabled: false
	},
	template: function() {
		if( this.get('href') )
			return "<a class='ui button {{# disabled}}disabled{{/}} {{# active}}active{{/}} {{ class }}' href='{{href}}'  style='{{style}}' title='{{title}}'>{{yield}}</a>"
		else
			return "<div type='button' class='ui {{#if disabled}}disabled{{/if}} {{#if active}}active{{/if}} button {{ class }}' onclick='onclick' {{#if ! disabled}}on-click=\"@this.fire('buttonclick', value)\" {{/if}} style='{{style}}' title='{{title}}{{tooltip}}'>{{yield}}</div>"
	}
})

/* icon */

Ractive.components['icon'] = Ractive.extend({template: "<i class='icon {{class}}'></i>"})




/* Pagination */

Ractive.components['pagination'] = Ractive.extend({
	isolated: true,
	data: {
		min: 1,
		max: 10,
		value: 1
	},
	computed: {
		pages: function() {
			var min = this.get('min')
			var max = this.get('max')
			var list = []
			for( var i = min; i <= max; i++ )
				list.push(i)
			return list
		}
	},
	template: "<nav><ul class='pagination {{#type}}pagination-{{type}}{{/}}'>{{#each pages}}<li {{#if . == value}}class='active'{{/if}}><a {{#url}}href='{{url}}{{.}}'{{/}} on-click='@this.set(\"value\", .)'>{{.}}</a></li>{{/each}}</ul></nav>"
})
