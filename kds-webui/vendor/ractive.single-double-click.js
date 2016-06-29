/**
 * jQuery-like implementation of single and double click handlers.
 *
 * https://github.com/sigod/ractive.single-double-click.js
 *
 * @author sigod
 * @license https://github.com/sigod/ractive.single-double-click.js/blob/master/LICENSE
 */
;(function () {
	'use strict';

	if (Ractive.events.singleclick && Ractive.events.doubleclick)
		return;

	Ractive.events.singleclick = eventHandler.bind(null, 'click');
	Ractive.events.doubleclick = eventHandler.bind(null, 'dblclick');

	var nodes = [];

	function indexOf(node) {
		for (var i = 0; i < nodes.length; ++i) {
			if (nodes[i].node === node) return i;
		}

		return -1;
	}

	function eventHandler(name, node, fire) {
		var clicks = 0;

		var _node = nodes[indexOf(node)];

		if (!_node) {
			_node = { node: node };
			_node[name] = fire;
			nodes.push(_node);

			node.addEventListener('click', onclick);
		}
		else {
			_node[name] = fire;
		}

		return {
			teardown: function () {
				var index = indexOf(node);

				if (index !== -1) {
					node.removeEventListener('click', onclick);
					nodes.splice(index, 1);
				}
			}
		};


		function onclick(event) {
			if (++clicks === 1) {
				setTimeout(function () {
					var _node = nodes[indexOf(node)];

					if (clicks === 1) {
						if (_node.click) _node.click({ node: node, original: event });
					}
					else {
						if (_node.dblclick) _node.dblclick({ node: node, original: event });
					}

					clicks = 0;
				}, 300);
			}
		}
	}
})();
