## Adding a new page:

firstly, for adding a new page;

	#new-page(data-role='page', data-theme='a'). 
where new-page's name ``#new-page`` set the your new page name.



for adding button on menu and showing like as ``new-page``, in app.ls files find to menu and write the links like as giving below code;

	RactivePartial!register ->
		menu =
			links:
				* name: 'new-page'
				  addr: '#/new-page'

for adding pictures or files, in app.ls files write the links like as giving below code;

	RactivePartial!register ->
		new-page =
			* label: 'uzaktan-kumanda'
			src: 'projects/pcb/kumanda/test.png'

		app.set \page.new-page, new-page
