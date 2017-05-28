/* Alerts */

Ractive.components['alert'] = Ractive.extend({
	isolated: true,
	data: {
		id: '',
		closable: false,
		hidden: false,
		type: 'info'
	},
	template: "<div {{#id}}id='{{id}}'{{/id}} {{#hidden}}hidden{{/hidden}} class='alert alert-{{type}} {{#closable}}alert-dismissible{{/closable}}'>{{#closable}}<button type='button' class='close' data-dismiss='alert'>&times;</button>{{/closable}}{{yield}}</div>"
})


/* Button groups */

Ractive.components['btn-group'] = Ractive.extend({isolated: true, template: "<div class='btn-group {{#type}}btn-group-{{type}}{{/type}}'>{{yield}}</div>"})
Ractive.components['btn-group-justified'] = Ractive.extend({isolated: true, template: "<div class='btn-group btn-group-justified {{#type}}btn-group-{{type}}{{/type}}'>{{yield}}</div>"})
Ractive.components['btn-group-vertical'] = Ractive.extend({isolated: true, template: "<div class='btn-group-vertical {{#type}}btn-group-{{type}}{{/type}}'>{{yield}}</div>"})
Ractive.components['btn-toolbar'] = Ractive.extend({isolated: true, template: "<div class='btn-toolbar'>{{yield}}</div>"})


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
			return      "<a class='ui button {{type.replace(/ +/g,\" btn-\")}} {{#disabled}}disabled{{/}} {{#active}}active{{/}} {{ class }}' href='{{href}}'  style='{{style}}' title='{{title}}'>{{yield}}</a>"
		else
			return "<button type='button' class='ui button {{type.replace(/ +/g,\" btn-\")}} {{#disabled}}disabled{{/}} {{#active}}active{{/}} {{ class }}' onclick='onclick' {{#if ! disabled}}on-click=\"@this.fire('buttonclick', value)\" {{/if}} style='{{style}}' title='{{title}}{{tooltip}}'>{{yield}}</button>"
	}
})


/* Dropdowns */

Ractive.components['caret'] = Ractive.extend({isolated: true, template: "<span class='caret'></span>"})
Ractive.components['dropdown'] = Ractive.extend({isolated: true, template: "<div class='btn-group'>{{yield}}</div>"})
Ractive.components['dropup'] = Ractive.extend({isolated: true, template: "<div class='btn-group dropup'>{{yield}}</div>"})
Ractive.components['dd-toggle'] = Ractive.extend({isolated: true, template: "<div data-toggle='dropdown'>{{yield}}</div>"})
Ractive.components['dd-menu'] = Ractive.extend({isolated: true, template: "<ul class='dropdown-menu' role='menu'>{{yield}}</ul>"})
Ractive.components['dd-menu-right'] = Ractive.extend({isolated: true, template: "<ul class='dropdown-menu dropdown-menu-right' role='menu'>{{yield}}</ul>"})
Ractive.components['dd-item'] = Ractive.extend({isolated: true, template: "<li><a href='{{href}}' onclick='{{onclick}}' on-click=\"@this.fire('select')\">{{yield}}</a></li>"})
Ractive.components['dd-header'] = Ractive.extend({isolated: true, template: "<li class='dropdown-header'>{{yield}}</li>"})
Ractive.components['dd-divider'] = Ractive.extend({isolated: true, template: "<li class='divider'></li>"})


/* Forms */

Ractive.components['form-inline'] = Ractive.extend({isolated: true, template: "<form class='form-inline'>{{yield}}</form>"})
Ractive.components['form-horizontal'] = Ractive.extend({isolated: true, template: "<form class='form-horizontal'>{{yield}}</form>"})
Ractive.components['form-group'] = Ractive.extend({isolated: true, template: "<div class='form-group'>{{yield}}</div>"})
Ractive.components['b-label'] = Ractive.extend({isolated: true, template: "<label class='control-label {{class}}' for='{{.for}}'>{{yield}}</label>"})

/* icon */

Ractive.components['icon'] = Ractive.extend({template: "<i class='icon {{class}}'></i>"})

/* Input groups */

Ractive.components['input-group'] = Ractive.extend({isolated: true, template: "<div class='input-group {{#type}}input-group-{{type}}{{/type}}'>{{yield}}</div>"})
Ractive.components['ig-addon'] = Ractive.extend({isolated: true, template: "<span class='input-group-addon'>{{yield}}</span>"})
Ractive.components['ig-btn'] = Ractive.extend({isolated: true, template: "<span class='input-group-btn'>{{yield}}</span>"})



/* Jumbotron & Page header */

Ractive.components['jumbotron'] = Ractive.extend({isolated: true, template: "<div class='jumbotron'>{{yield}}</div>"})
Ractive.components['page-header'] = Ractive.extend({isolated: true, template: "<div class='page-header'>{{yield}}</div>"})


/* Modals */

Ractive.components['modal'] = Ractive.extend({
	isolated: true,
	data: {
		onshow: "",
		onclose: "",
		onsave: "",
		type: "",
		title: "",
		id: "",
		cancel: "Cancel",
		save: "Save"
	},
	template:
		"<modal-custom id='{{id}}' onshow='{{onshow}}' onclose='{{onclose}}' type='{{type}}' >" +
			"<modal-header>" +
				"<modal-close/>" +
				"<h4 class='modal-title'>{{title}}</h4>" +
			"</modal-header>" +
			"<modal-body>" +
				"{{yield}}" +
			"</modal-body>" +
			"<modal-footer>" +
				"{{#save}}<button class='btn btn-primary' onclick='{{onsave}}'>{{save}}</button>{{/save}}" +
				"{{#cancel}}<button class='btn btn-default' data-dismiss='modal'>{{cancel}}</button>{{/cancel}}" +
			"</modal-footer>" +
	"</modal-custom>"
})

Ractive.components['modal-custom'] = Ractive.extend({
	isolated: true,
	data: {
		id: "",
		type: "",
		onshow: "",
		onclose: "",
		keyboard: true,
		backdrop: "static"
	},
	template: "<div class='modal fade' {{#id}}id='{{id}}'{{/id}} tabindex='-1' role='dialog' aria-hidden='true' data-backdrop='{{backdrop}}' data-keyboard='{{keyboard}}'><div class='modal-dialog {{#type}}modal-{{type}}{{/}}'><div class='modal-content'>{{yield}}</div></div></div>",
	onrender: function() {
		var elem = this.find('*')

		var onclose = this.get('onclose')
		if( onclose ) {
			$(elem).bind('hide.bs.modal', function(event) {
				eval(onclose) // jshint ignore:line
			})
		}

		var onshow = this.get('onshow')
		if( onshow ) {
			$(elem).bind('show.bs.modal', function(event) {
				eval(onshow) // jshint ignore:line
			})
		}
	}
})

Ractive.components['modal-header'] = Ractive.extend({
	isolated: true,
	template: "<div class='modal-header'>{{yield}}</div>"
})

Ractive.components['modal-body'] = Ractive.extend({
	isolated: true,
	template: "<div class='modal-body'>{{yield}}</div>"
})

Ractive.components['modal-footer'] = Ractive.extend({
	isolated: true,
	template: "<div class='modal-footer'>{{yield}}</div>"
})

Ractive.components['modal-close'] = Ractive.extend({
	isolated: true,
	template: "<button type='button' class='close' aria-label='Close' data-dismiss='modal'><span aria-hidden='true'>&times;</span></button>"
})


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


/* Panels */

Ractive.components['panel'] = Ractive.extend({
	isolated: true,
	data: {
		type: 'default',
		hidden: false,
		style:'',
		icon: '',
		class: ''
	},
	template: "<panel-custom type='{{type}}' hidden='{{hidden}}' class='{{class}}'>{{#title}}<panel-heading style='{{style}}'>{{#icon}}<icon name='{{icon}}'/> {{/icon}}{{title}}</panel-heading>{{/title}}<panel-body>{{yield}}</panel-body>{{#footer}}<panel-footer>{{footer}}</panel-footer>{{/footer}}</panel-custom>"
})
Ractive.components['panel-custom'] = Ractive.extend({
	isolated: true,
	data: { type: 'default' },
	template: "<div class='panel panel-{{type}} {{class}}' hidden='{{hidden}}'>{{yield}}</div>"
})
Ractive.components['panel-heading'] = Ractive.extend({isolated: true, data:{style:null}, template: "<div class='panel-heading' style='{{style}}'>{{yield}}</div>"})
Ractive.components['panel-body'] = Ractive.extend({isolated: true, template: "<div class='panel-body'>{{yield}}</div>"})
Ractive.components['panel-footer'] = Ractive.extend({isolated: true, template: "<div class='panel-footer'>{{yield}}</div>"})


/* Tables */

Ractive.components['b-table'] = Ractive.extend({
	isolated: true,
	data:{ type:"striped hover" },
	template: "<table class='table {{#type}}table-{{type.replace(/ +/g,\" table-\")}}{{/type}}'>{{yield}}</table>"
})


/* Tabs & Pills */

Ractive.components['tabs'] = Ractive.extend({
	isolated: true,
	data: {
		type: ''
	},
	template: "<ul class='nav nav-tabs nav-{{type.replace(/ +/g,\" nav-\")}}'>{{yield}}</ul>"
})

Ractive.components['pills'] = Ractive.extend({
	isolated: true,
	data: {
		type: ''
	},
	template: "<ul class='nav nav-pills nav-{{type.replace(/ +/g,\" nav-\")}}'>{{yield}}</ul>"
})

Ractive.components['tab'] = Ractive.extend({
	isolated: true,
	data: {
		href: '#',
		active: false,
		disabled: false
	},
	template: "<li role='presentation' class='{{#active}}active{{/}} {{#disabled}}disabled{{/}}'><a href='{{href}}' on-click='@this.selectIt()'>{{yield}}</a></li>",
	selectIt: function() {
		if( this.get('disabled') )
			return
		this.container.set('selected', this.get('name'))
		// return false
	},
	onrender: function() {
		var container = this.container
		var self = this
		self.container.observe('selected', function( selected ) {
			if( !selected )
				return
			var name = self.get('name')
			self.set('active', name === selected )
		})
	}
})

Ractive.components['pill'] = Ractive.components['tab'] // They are identical

/* Tags & Badges */

Ractive.components['tag'] = Ractive.extend({isolated: true, data: {type: 'default', size: null}, template: "<span class='label label-{{type}}' style='{{#if size}}font-size: {{size}}; line-height: {{size}} {{/if}}' >{{yield}}</span>"})
Ractive.components['badge'] = Ractive.extend({isolated: true, template: "<span class='badge'>{{yield}}</span>"})
