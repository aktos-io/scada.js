var tooltipDecorator = function ( node, content ) {
    var tooltip, handlers, eventName;

    handlers = {
        mouseover: function () {
            tooltip = document.createElement( tooltipDecorator.elementName );
            tooltip.className = tooltipDecorator.className;
            tooltip.textContent = content;

            node.parentNode.insertBefore( tooltip, node );
        },

        mousemove: function ( event ) {
            tooltip.style.left = event.clientX + tooltipDecorator.offsetX + 'px';
            tooltip.style.top = ( event.clientY - tooltip.clientHeight + tooltipDecorator.offsetY ) + 'px';
        },

        mouseleave: function () {
            tooltip.parentNode.removeChild( tooltip );
        }
    };

    for ( eventName in handlers ) {
        if ( handlers.hasOwnProperty( eventName ) ) {
            node.addEventListener( eventName, handlers[ eventName ], false );
        }
    }

    return {
        teardown: function () {
            for ( eventName in handlers ) {
                if ( handlers.hasOwnProperty( eventName ) ) {
                    node.removeEventListener( eventName, handlers[ eventName ], false );
                }
            }
        }
    }
};

tooltipDecorator.className = 'ractive-tooltip';
tooltipDecorator.element = 'p';
tooltipDecorator.offsetX = 0;
tooltipDecorator.offsetY = -20;

Ractive.decorators.tooltip = tooltipDecorator;
