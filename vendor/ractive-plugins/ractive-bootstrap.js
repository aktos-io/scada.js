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
			return      "<a class='btn btn-{{type.replace(/ +/g,\" btn-\")}} {{#disabled}}disabled{{/}} {{#active}}active{{/}} {{#dropdown}}dropdown-toggle{{/}} {{ class }}' {{#dropdown}}data-toggle='dropdown'{{/}} href='{{href}}'  style='{{style}}' title='{{title}}'>{{yield}}</a>"
		else
			return "<button type='button' class='btn btn-{{type.replace(/ +/g,\" btn-\")}} {{#disabled}}disabled{{/}} {{#active}}active{{/}} {{#dropdown}}dropdown-toggle{{/}} {{ class }}' {{#dropdown}}data-toggle='dropdown'{{/}} onclick='onclick' {{#if ! disabled}}on-click=\"@this.fire('buttonclick', value)\" {{/if}} style='{{style}}' title='{{title}}{{tooltip}}'>{{yield}}</button>"
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
/* Containers */

Ractive.components['container'] = Ractive.extend({isolated: true, template: "<div class='container'>{{yield}}</div>"})
Ractive.components['container-fluid'] = Ractive.extend({isolated: true, template: "<div class='container-fluid'>{{yield}}</div>"})

/* Row */

Ractive.components['row'] = Ractive.extend({isolated: true, template: "<div class='row'>{{yield}}</div>"})

/* Columns */

Ractive.components['column'] = Ractive.extend({isolated: true, template: "<div class='{{#xs}}col-xs-{{xs}}{{/}} {{#sm}}col-sm-{{sm}}{{/}} {{#md}}col-md-{{md}}{{/}} {{#lg}}col-lg-{{lg}}{{/}}'>{{yield}}</div>"})

/* Columns XS */

Ractive.components['col-xs-1'] = Ractive.extend({isolated: true, template: "<div class='col-xs-1'>{{yield}}</div>"})
Ractive.components['col-xs-2'] = Ractive.extend({isolated: true, template: "<div class='col-xs-2'>{{yield}}</div>"})
Ractive.components['col-xs-3'] = Ractive.extend({isolated: true, template: "<div class='col-xs-3'>{{yield}}</div>"})
Ractive.components['col-xs-4'] = Ractive.extend({isolated: true, template: "<div class='col-xs-4'>{{yield}}</div>"})
Ractive.components['col-xs-5'] = Ractive.extend({isolated: true, template: "<div class='col-xs-5'>{{yield}}</div>"})
Ractive.components['col-xs-6'] = Ractive.extend({isolated: true, template: "<div class='col-xs-6'>{{yield}}</div>"})
Ractive.components['col-xs-7'] = Ractive.extend({isolated: true, template: "<div class='col-xs-7'>{{yield}}</div>"})
Ractive.components['col-xs-8'] = Ractive.extend({isolated: true, template: "<div class='col-xs-8'>{{yield}}</div>"})
Ractive.components['col-xs-9'] = Ractive.extend({isolated: true, template: "<div class='col-xs-9'>{{yield}}</div>"})
Ractive.components['col-xs-10'] = Ractive.extend({isolated: true, template: "<div class='col-xs-10'>{{yield}}</div>"})
Ractive.components['col-xs-11'] = Ractive.extend({isolated: true, template: "<div class='col-xs-11'>{{yield}}</div>"})
Ractive.components['col-xs-12'] = Ractive.extend({isolated: true, template: "<div class='col-xs-12'>{{yield}}</div>"})

/* Columns SM */

Ractive.components['col-sm-1'] = Ractive.extend({isolated: true, template: "<div class='col-sm-1'>{{yield}}</div>"})
Ractive.components['col-sm-2'] = Ractive.extend({isolated: true, template: "<div class='col-sm-2'>{{yield}}</div>"})
Ractive.components['col-sm-3'] = Ractive.extend({isolated: true, template: "<div class='col-sm-3'>{{yield}}</div>"})
Ractive.components['col-sm-4'] = Ractive.extend({isolated: true, template: "<div class='col-sm-4'>{{yield}}</div>"})
Ractive.components['col-sm-5'] = Ractive.extend({isolated: true, template: "<div class='col-sm-5'>{{yield}}</div>"})
Ractive.components['col-sm-6'] = Ractive.extend({isolated: true, template: "<div class='col-sm-6'>{{yield}}</div>"})
Ractive.components['col-sm-7'] = Ractive.extend({isolated: true, template: "<div class='col-sm-7'>{{yield}}</div>"})
Ractive.components['col-sm-8'] = Ractive.extend({isolated: true, template: "<div class='col-sm-8'>{{yield}}</div>"})
Ractive.components['col-sm-9'] = Ractive.extend({isolated: true, template: "<div class='col-sm-9'>{{yield}}</div>"})
Ractive.components['col-sm-10'] = Ractive.extend({isolated: true, template: "<div class='col-sm-10'>{{yield}}</div>"})
Ractive.components['col-sm-11'] = Ractive.extend({isolated: true, template: "<div class='col-sm-11'>{{yield}}</div>"})
Ractive.components['col-sm-12'] = Ractive.extend({isolated: true, template: "<div class='col-sm-12'>{{yield}}</div>"})

/* Columns MD */

Ractive.components['col-md-1'] = Ractive.extend({isolated: true, template: "<div class='col-md-1'>{{yield}}</div>"})
Ractive.components['col-md-2'] = Ractive.extend({isolated: true, template: "<div class='col-md-2'>{{yield}}</div>"})
Ractive.components['col-md-3'] = Ractive.extend({isolated: true, template: "<div class='col-md-3'>{{yield}}</div>"})
Ractive.components['col-md-4'] = Ractive.extend({isolated: true, template: "<div class='col-md-4'>{{yield}}</div>"})
Ractive.components['col-md-5'] = Ractive.extend({isolated: true, template: "<div class='col-md-5'>{{yield}}</div>"})
Ractive.components['col-md-6'] = Ractive.extend({isolated: true, template: "<div class='col-md-6'>{{yield}}</div>"})
Ractive.components['col-md-7'] = Ractive.extend({isolated: true, template: "<div class='col-md-7'>{{yield}}</div>"})
Ractive.components['col-md-8'] = Ractive.extend({isolated: true, template: "<div class='col-md-8'>{{yield}}</div>"})
Ractive.components['col-md-9'] = Ractive.extend({isolated: true, template: "<div class='col-md-9'>{{yield}}</div>"})
Ractive.components['col-md-10'] = Ractive.extend({isolated: true, template: "<div class='col-md-10'>{{yield}}</div>"})
Ractive.components['col-md-11'] = Ractive.extend({isolated: true, template: "<div class='col-md-11'>{{yield}}</div>"})
Ractive.components['col-md-12'] = Ractive.extend({isolated: true, template: "<div class='col-md-12'>{{yield}}</div>"})

/* Columns LG */

Ractive.components['col-lg-1'] = Ractive.extend({isolated: true, template: "<div class='col-lg-1'>{{yield}}</div>"})
Ractive.components['col-lg-2'] = Ractive.extend({isolated: true, template: "<div class='col-lg-2'>{{yield}}</div>"})
Ractive.components['col-lg-3'] = Ractive.extend({isolated: true, template: "<div class='col-lg-3'>{{yield}}</div>"})
Ractive.components['col-lg-4'] = Ractive.extend({isolated: true, template: "<div class='col-lg-4'>{{yield}}</div>"})
Ractive.components['col-lg-5'] = Ractive.extend({isolated: true, template: "<div class='col-lg-5'>{{yield}}</div>"})
Ractive.components['col-lg-6'] = Ractive.extend({isolated: true, template: "<div class='col-lg-6'>{{yield}}</div>"})
Ractive.components['col-lg-7'] = Ractive.extend({isolated: true, template: "<div class='col-lg-7'>{{yield}}</div>"})
Ractive.components['col-lg-8'] = Ractive.extend({isolated: true, template: "<div class='col-lg-8'>{{yield}}</div>"})
Ractive.components['col-lg-9'] = Ractive.extend({isolated: true, template: "<div class='col-lg-9'>{{yield}}</div>"})
Ractive.components['col-lg-10'] = Ractive.extend({isolated: true, template: "<div class='col-lg-10'>{{yield}}</div>"})
Ractive.components['col-lg-11'] = Ractive.extend({isolated: true, template: "<div class='col-lg-11'>{{yield}}</div>"})
Ractive.components['col-lg-12'] = Ractive.extend({isolated: true, template: "<div class='col-lg-12'>{{yield}}</div>"})


/* Glyphicons */

var icons = [
	"asterisk",
	"plus",
	"euro",
	"eur",
	"minus",
	"cloud",
	"envelope",
	"pencil",
	"glass",
	"music",
	"search",
	"heart",
	"star",
	"star-empty",
	"user",
	"film",
	"th-large",
	"th",
	"th-list",
	"ok",
	"remove",
	"zoom-in",
	"zoom-out",
	"off",
	"signal",
	"cog",
	"trash",
	"home",
	"file",
	"time",
	"road",
	"download-alt",
	"download",
	"upload",
	"inbox",
	"play-circle",
	"repeat",
	"refresh",
	"list-alt",
	"lock",
	"flag",
	"headphones",
	"volume-off",
	"volume-down",
	"volume-up",
	"qrcode",
	"barcode",
	"tag",
	"tags",
	"book",
	"bookmark",
	"print",
	"camera",
	"font",
	"bold",
	"italic",
	"text-height",
	"text-width",
	"align-left",
	"align-center",
	"align-right",
	"align-justify",
	"list",
	"indent-left",
	"indent-right",
	"facetime-video",
	"picture",
	"map-marker",
	"adjust",
	"tint",
	"edit",
	"share",
	"check",
	"move",
	"step-backward",
	"fast-backward",
	"backward",
	"play",
	"pause",
	"stop",
	"forward",
	"fast-forward",
	"step-forward",
	"eject",
	"chevron-left",
	"chevron-right",
	"plus-sign",
	"minus-sign",
	"remove-sign",
	"ok-sign",
	"question-sign",
	"info-sign",
	"screenshot",
	"remove-circle",
	"ok-circle",
	"ban-circle",
	"arrow-left",
	"arrow-right",
	"arrow-up",
	"arrow-down",
	"share-alt",
	"resize-full",
	"resize-small",
	"exclamation-sign",
	"gift",
	"leaf",
	"fire",
	"eye-open",
	"eye-close",
	"warning-sign",
	"plane",
	"calendar",
	"random",
	"comment",
	"magnet",
	"chevron-up",
	"chevron-down",
	"retweet",
	"shopping-cart",
	"folder-close",
	"folder-open",
	"resize-vertical",
	"resize-horizontal",
	"hdd",
	"bullhorn",
	"bell",
	"certificate",
	"thumbs-up",
	"thumbs-down",
	"hand-right",
	"hand-left",
	"hand-up",
	"hand-down",
	"circle-arrow-right",
	"circle-arrow-left",
	"circle-arrow-up",
	"circle-arrow-down",
	"globe",
	"wrench",
	"tasks",
	"filter",
	"briefcase",
	"fullscreen",
	"dashboard",
	"paperclip",
	"heart-empty",
	"link",
	"phone",
	"pushpin",
	"usd",
	"gbp",
	"sort",
	"sort-by-alphabet",
	"sort-by-alphabet-alt",
	"sort-by-order",
	"sort-by-order-alt",
	"sort-by-attributes",
	"sort-by-attributes-alt",
	"unchecked",
	"expand",
	"collapse-down",
	"collapse-up",
	"log-in",
	"flash",
	"log-out",
	"new-window",
	"record",
	"save",
	"open",
	"saved",
	"import",
	"export",
	"send",
	"floppy-disk",
	"floppy-saved",
	"floppy-remove",
	"floppy-save",
	"floppy-open",
	"credit-card",
	"transfer",
	"cutlery",
	"header",
	"compressed",
	"earphone",
	"phone-alt",
	"tower",
	"stats",
	"sd-video",
	"hd-video",
	"subtitles",
	"sound-stereo",
	"sound-dolby",
	"sound-5-1",
	"sound-6-1",
	"sound-7-1",
	"copyright-mark",
	"registration-mark",
	"cloud-download",
	"cloud-upload",
	"tree-conifer",
	"tree-deciduous",
	"cd",
	"save-file",
	"open-file",
	"level-up",
	"copy",
	"paste",
	"alert",
	"equalizer",
	"king",
	"queen",
	"pawn",
	"bishop",
	"knight",
	"baby-formula",
	"tent",
	"blackboard",
	"bed",
	"apple",
	"erase",
	"hourglass",
	"lamp",
	"duplicate",
	"piggy-bank",
	"scissors",
	"bitcoin",
	"btc",
	"xbt",
	"yen",
	"jpy",
	"ruble",
	"rub",
	"scale",
	"ice-lolly",
	"ice-lolly-tasted",
	"education",
	"option-horizontal",
	"option-vertical",
	"menu-hamburger",
	"modal-window",
	"oil",
	"grain",
	"sunglasses",
	"text-size",
	"text-color",
	"text-background",
	"object-align-top",
	"object-align-bottom",
	"object-align-horizontal",
	"object-align-left",
	"object-align-vertical",
	"object-align-right",
	"triangle-right",
	"triangle-left",
	"triangle-bottom",
	"triangle-top",
	"console",
	"superscript",
	"subscript",
	"menu-left",
	"menu-right",
	"menu-down",
	"menu-up"
]

Ractive.components['icon'] = Ractive.extend({template: "<span class='glyphicon glyphicon-{{name}}' aria-hidden='true' title='{{title}}'></span>"})
for( var i in icons ) {
	Ractive.components['icon-' + icons[i]] = Ractive.extend({template: "<icon/>", data: {name: icons[i]}})
}

icons = undefined

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
		icon: ''
	},
	template: "<panel-custom type='{{type}}' hidden='{{hidden}}'>{{#title}}<panel-heading style='{{style}}'>{{#icon}}<icon name='{{icon}}'/> {{/icon}}{{title}}</panel-heading>{{/title}}<panel-body>{{yield}}</panel-body>{{#footer}}<panel-footer>{{footer}}</panel-footer>{{/footer}}</panel-custom>"
})
Ractive.components['panel-custom'] = Ractive.extend({
	isolated: true,
	data: { type: 'default' },
	template: "<div class='panel panel-{{type}}' hidden='{{hidden}}'>{{yield}}</div>"
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

Ractive.components['tag'] = Ractive.extend({isolated: true, data: {type: 'default', size: null}, template: "<span class='label label-{{type}}' style='{{#if size}}font-size: {{size}}; {{/if}}' >{{yield}}</span>"})
Ractive.components['badge'] = Ractive.extend({isolated: true, template: "<span class='badge'>{{yield}}</span>"})
