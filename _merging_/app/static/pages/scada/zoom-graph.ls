


	get-data = ->
		d = [];
		for i from 1 to 100 by 1
			x = x1 + i * (x2-x1) / 100
			d.push [x,Math.sin(x*Math.sin(x))]
			