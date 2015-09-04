// version: 2015-02-21
    /**
    * o--------------------------------------------------------------------------------o
    * | This file is part of the RGraph package - you can learn more at:               |
    * |                                                                                |
    * |                          http://www.rgraph.net                                 |
    * |                                                                                |
    * | This package is licensed under the Creative Commons BY-NC license. That means  |
    * | that for non-commercial purposes it's free to use and for business use there's |
    * | a 99 GBP per-company fee to pay. You can read the full license here:           |
    * |                                                                                |
    * |                      http://www.rgraph.net/license                             |
    * o--------------------------------------------------------------------------------o
    */

    RGraph = window.RGraph || {isRGraph: true};

    /**
    * The chart constuctor
    * 
    * @param object canvas
    * @param array data
    */
    RGraph.RScatter =
    RGraph.Rscatter = function (conf)
    {
        /**
        * Allow for object config style
        */
        if (   typeof conf === 'object'
            && typeof conf.data === 'object'
            && typeof conf.id === 'string') {

            var parseConfObjectForOptions = true; // Set this so the config is parsed (at the end of the constructor)

            this.data = new Array(conf.data.length);

           // Store the data set(s)
            this.data = RGraph.arrayClone(conf.data);


            // Account for just one dataset being given
            if (typeof conf.data === 'object' && typeof conf.data[0] === 'object' && typeof conf.data[0][0] === 'number') {
                var tmp = RGraph.arrayClone(conf.data);
                conf.data = new Array();
                conf.data[0] = RGraph.arrayClone(tmp);
                
                this.data = RGraph.arrayClone(conf.data);
            }

        } else {
        
            var conf      = {id: conf};
                conf.data = arguments[1];


            this.data = [];

            // Handle multiple datasets being given as one argument
            if (arguments[1][0] && arguments[1][0][0] && typeof arguments[1][0][0] == 'object') {
                // Store the data set(s)
                for (var i=0; i<arguments[1].length; ++i) {
                    this.data[i] = arguments[1][i];
                }
    
            // Handle multiple data sets being supplied as seperate arguments
            } else {

                // Store the data set(s)
                for (var i=1; i<arguments.length; ++i) {
                    this.data[i - 1] = RGraph.array_clone(arguments[i]);
                }
            }
        }




        this.id                = conf.id
        this.canvas            = document.getElementById(this.id)
        this.context           = this.canvas.getContext ? this.canvas.getContext("2d") : null;
        this.canvas.__object__ = this;
        this.type              = 'rscatter';
        this.hasTooltips       = false;
        this.isRGraph          = true;
        this.uid               = RGraph.CreateUID();
        this.canvas.uid        = this.canvas.uid ? this.canvas.uid : RGraph.CreateUID();
        this.colorsParsed      = false;
        this.coordsText        = [];
        this.original_colors   = [];
        this.firstDraw         = true; // After the first draw this will be false


        /**
        * Compatibility with older browsers
        */
        //RGraph.OldBrowserCompat(this.context);


        this.centerx = 0;
        this.centery = 0;
        this.radius  = 0;
        this.max     = 0;
        
        this.properties =
        {
            'chart.radius':                 null,
            'chart.colors':                 [], // This is used internally for the key
            'chart.colors.default':         'black',
            'chart.gutter.left':            25,
            'chart.gutter.right':           25,
            'chart.gutter.top':             25,
            'chart.gutter.bottom':          25,
            'chart.title':                  '',
            'chart.title.background':       null,
            'chart.title.hpos':             null,
            'chart.title.vpos':             null,
            'chart.title.bold':             true,
            'chart.title.font':             null,
            'chart.title.x':                null,
            'chart.title.y':                null,
            'chart.title.halign':           null,
            'chart.title.valign':           null,
            'chart.labels':                 null,
            'chart.labels.position':       'center',
            'chart.labels.axes':            'nsew',
            'chart.text.color':             'black',
            'chart.text.font':              'Arial',
            'chart.text.size':              10,
            'chart.key':                    null,
            'chart.key.background':         'white',
            'chart.key.position':           'graph',
            'chart.key.halign':             'right',
            'chart.key.shadow':             false,
            'chart.key.shadow.color':       '#666',
            'chart.key.shadow.blur':        3,
            'chart.key.shadow.offsetx':     2,
            'chart.key.shadow.offsety':     2,
            'chart.key.position.gutter.boxed':false,
            'chart.key.position.x':         null,
            'chart.key.position.y':         null,
            'chart.key.color.shape':        'square',
            'chart.key.rounded':            true,
            'chart.key.linewidth':          1,
            'chart.key.colors':             null,
            'chart.key.interactive':        false,
            'chart.key.interactive.highlight.chart.fill':'rgba(255,0,0,0.9)',
            'chart.key.interactive.highlight.label':'rgba(255,0,0,0.2)',
            'chart.key.text.color':         'black',
            'chart.contextmenu':            null,
            'chart.tooltips':               null,
            'chart.tooltips.event':        'onmousemove',
            'chart.tooltips.effect':        'fade',
            'chart.tooltips.css.class':     'RGraph_tooltip',
            'chart.tooltips.highlight':     true,
            'chart.tooltips.hotspot':       3,
            'chart.tooltips.coords.page':   false,
            'chart.annotatable':            false,
            'chart.annotate.color':         'black',
            'chart.zoom.factor':            1.5,
            'chart.zoom.fade.in':           true,
            'chart.zoom.fade.out':          true,
            'chart.zoom.hdir':              'right',
            'chart.zoom.vdir':              'down',
            'chart.zoom.frames':            25,
            'chart.zoom.delay':             16.666,
            'chart.zoom.shadow':            true,
            'chart.zoom.background':        true,
            'chart.zoom.action':            'zoom',
            'chart.resizable':              false,
            'chart.resize.handle.background': null,
            'chart.ymax':                   null,
            'chart.ymin':                   0,
            'chart.tickmarks':              'cross',
            'chart.ticksize':               3,
            'chart.scale.decimals':         null,
            'chart.scale.point':            '.',
            'chart.scale.thousand':         ',',
            'chart.scale.round':            false,
            'chart.units.pre':              '',
            'chart.units.post':             '',
            'chart.events.mousemove':       null,
            'chart.events.click':           null,
            'chart.highlight.stroke':       'transparent',
            'chart.highlight.fill':         'rgba(255,255,255,0.7)',
            'chart.highlight.point.radius': 3,
            'chart.labels.count':          5
        }
        



        /**
        * Create the $ objects so that functions can be added to them
        */

        for (var i=0,idx=0; i<this.data.length; ++i) {
            for (var j=0,len=this.data[i].length; j<len; j+=1,idx+=1) {
                this['$' + idx] = {}
            }
        }





        /**
        * Translate half a pixel for antialiasing purposes - but only if it hasn't beeen
        * done already
        */
        if (!this.canvas.__rgraph_aa_translated__) {
            this.context.translate(0.5,0.5);
            
            this.canvas.__rgraph_aa_translated__ = true;
        }




        // Short variable names
        var RG    = RGraph;
        var ca    = this.canvas;
        var co    = ca.getContext('2d');
        var prop  = this.properties;
        var jq    = jQuery;
        var pa    = RG.Path;
        var win   = window;
        var doc   = document;
        var ma    = Math;
        
        
        
        /**
        * "Decorate" the object with the generic effects if the effects library has been included
        */
        if (RG.Effects && typeof RG.Effects.decorate === 'function') {
            RG.Effects.decorate(this);
        }




        /**
        * A simple setter
        * 
        * @param string name  The name of the property to set
        * @param string value The value of the property
        */
        this.set =
        this.Set = function (name, value)
        {
            var value = typeof arguments[1] === 'undefined' ? null : arguments[1];

            /**
            * the number of arguments is only one and it's an
            * object - parse it for configuration data and return.
            */
            if (arguments.length === 1 && typeof name === 'object') {
                RG.parseObjectStyleConfig(this, name);
                return this;
            }



            /**
            * This should be done first - prepend the property name with "chart." if necessary
            */
            if (name.substr(0,6) != 'chart.') {
                name = 'chart.' + name;
            }
            prop[name.toLowerCase()] = value;
    
            return this;
        };




        /**
        * A simple getter
        * 
        * @param string name The name of the property to get
        */
        this.get =
        this.Get = function (name)
        {
            /**
            * This should be done first - prepend the property name with "chart." if necessary
            */
            if (name.substr(0,6) != 'chart.') {
                name = 'chart.' + name;
            }
    
            return prop[name.toLowerCase()];
        };




        /**
        * This method draws the rose chart
        */
        this.draw =
        this.Draw = function ()
        {
            /**
            * Fire the onbeforedraw event
            */
            RG.FireCustomEvent(this, 'onbeforedraw');
    
    
            /**
            * This doesn't affect the chart, but is used for compatibility
            */
            this.gutterLeft   = prop['chart.gutter.left'];
            this.gutterRight  = prop['chart.gutter.right'];
            this.gutterTop    = prop['chart.gutter.top'];
            this.gutterBottom = prop['chart.gutter.bottom'];
    
            // Calculate the radius
            this.radius  = (Math.min(ca.width - this.gutterLeft - this.gutterRight, ca.height - this.gutterTop - this.gutterBottom) / 2);
            this.centerx = ((ca.width - this.gutterLeft - this.gutterRight) / 2) + this.gutterLeft;
            this.centery = ((ca.height - this.gutterTop - this.gutterBottom) / 2) + this.gutterTop;
            this.coords  = [];
            this.coords2 = [];



            /**
            * Stop this growing uncontrollably
            */
            this.coordsText = [];




            /**
            * If there's a user specified radius/centerx/centery, use them
            */
            if (typeof(prop['chart.centerx']) == 'number') this.centerx = prop['chart.centerx'];
            if (typeof(prop['chart.centery']) == 'number') this.centery = prop['chart.centery'];
            if (typeof(prop['chart.radius'])  == 'number') this.radius  = prop['chart.radius'];
    
    
    
            /**
            * Parse the colors for gradients. Its down here so that the center X/Y can be used
            */
            if (!this.colorsParsed) {
    
                this.parseColors();
    
                // Don't want to do this again
                this.colorsParsed = true;
            }
    
    
            /**
            * Work out the scale
            */
            var max = prop['chart.ymax'];
            var min = prop['chart.ymin'];
            
            if (typeof(max) == 'number') {
                this.max    = max;
                this.scale2 = RG.getScale2(this, {'max':max,
                                                  'min':min,
                                                  'strict':true,
                                                  'scale.decimals':Number(prop['chart.scale.decimals']),
                                                  'scale.point':prop['chart.scale.point'],
                                                  'scale.thousand':prop['chart.scale.thousand'],
                                                  'scale.round':prop['chart.scale.round'],
                                                  'units.pre':prop['chart.units.pre'],
                                                  'units.post':prop['chart.units.post'],
                                                  'ylabels.count':prop['chart.labels.count']
                                                 });
            } else {
    
                for (var i=0; i<this.data.length; i+=1) {
                    for (var j=0,len=this.data[i].length; j<len; j+=1) {
                        this.max = Math.max(this.max, this.data[i][j][1]);
                    }
                }

                this.min = prop['chart.ymin'];
    
                this.scale2 = RG.getScale2(this, {'max':this.max,
                                                  'min':min,
                                                  'scale.decimals':Number(prop['chart.scale.decimals']),
                                                  'scale.point':prop['chart.scale.point'],
                                                  'scale.thousand':prop['chart.scale.thousand'],
                                                  'scale.round':prop['chart.scale.round'],
                                                  'units.pre':prop['chart.units.pre'],
                                                  'units.post':prop['chart.units.post'],
                                                  'ylabels.count':prop['chart.labels.count']
                                                 });
                this.max = this.scale2.max;
            }
    
            /**
            * Change the centerx marginally if the key is defined
            */
            if (prop['chart.key'] && prop['chart.key'].length > 0 && prop['chart.key'].length >= 3) {
                this.centerx = this.centerx - prop['chart.gutter.right'] + 5;
            }
            
            /**
            * Populate the colors array for the purposes of generating the key
            */
            if (typeof(prop['chart.key']) == 'object' && RG.is_array(prop['chart.key']) && prop['chart.key'][0]) {

                // Reset the colors array
                prop['chart.colors'] = [];

                for (var i=0; i<this.data.length; i+=1) {
                    for (var j=0,len=this.data[i].length; j<len; j+=1) {
                        if (typeof this.data[i][j][2] == 'string') {
                            prop['chart.colors'].push(this.data[i][j][2]);
                        }
                    }
                }
            }

    
    
    
            /**
            * Populate the chart.tooltips array
            */
            this.Set('chart.tooltips', []);

            for (var i=0; i<this.data.length; i+=1) {
                for (var j=0,len=this.data[i].length; j<len; j+=1) {
                    if (typeof this.data[i][j][3] == 'string') {
                        prop['chart.tooltips'].push(this.data[i][j][3]);
                    }
                }
            }
    
    
    
            // This resets the chart drawing state
            co.beginPath();
    
            this.DrawBackground();
            this.DrawRscatter();
            this.DrawLabels();
    
            /**
            * Setup the context menu if required
            */
            if (prop['chart.contextmenu']) {
                RG.ShowContext(this);
            }
    
    
    
            // Draw the title if any has been set
            if (prop['chart.title']) {
                RG.DrawTitle(this,
                             prop['chart.title'],
                             this.centery - this.radius - 10,
                             this.centerx,
                             prop['chart.title.size'] ? prop['chart.title.size'] : prop['chart.text.size'] + 2);
            }
    
            
            /**
            * This function enables resizing
            */
            if (prop['chart.resizable']) {
                RG.AllowResizing(this);
            }
    
    
            /**
            * This installs the event listeners
            */
            RG.InstallEventListeners(this);




            /**
            * Fire the onfirstdraw event
            */
            if (this.firstDraw) {
                RG.fireCustomEvent(this, 'onfirstdraw');
                this.firstDraw = false;
                this.firstDrawFunc();
            }




            /**
            * Fire the RGraph ondraw event
            */
            RG.FireCustomEvent(this, 'ondraw');




            return this;
        };




        /**
        * This method draws the rscatter charts background
        */
        this.drawBackground =
        this.DrawBackground = function ()
        {
            co.lineWidth = 1;
    
    
    
            // Draw the background grey circles
            co.strokeStyle = '#ccc'; // TODO Use a property here - eg chart.background.circles.color
            // Radius must be greater than 0 for Opera to work
            var r = this.radius / 10;
            for (var i=0,len=this.radius; i<=len; i+=r) {
                //co.moveTo(this.centerx + i, this.centery);
        
                // Radius must be greater than 0 for Opera to work
                co.arc(this.centerx, this.centery, i, 0, RG.TWOPI, 0);
            }
            co.stroke();
    
    
    
    
    
    
    
            // Draw the background lines that go from the center outwards
            co.beginPath();
            for (var i=15; i<360; i+=15) {
            
                // Radius must be greater than 0 for Opera to work
                co.arc(this.centerx, this.centery, this.radius, i / (180 / RG.PI), (i + 0.01) / (180 / RG.PI), 0);
            
                co.lineTo(this.centerx, this.centery);
            }
            co.stroke();
    
    
    
    
    
    
    
    
    
    
    
    
    
            co.beginPath();
            co.strokeStyle = 'black';
        
            // Draw the X axis
            co.moveTo(this.centerx - this.radius, Math.round(this.centery));
            co.lineTo(this.centerx + this.radius, Math.round(this.centery));
        
            // Draw the X ends
            co.moveTo(Math.round(this.centerx - this.radius), this.centery - 5);
            co.lineTo(Math.round(this.centerx - this.radius), this.centery + 5);
            co.moveTo(Math.round(this.centerx + this.radius), this.centery - 5);
            co.lineTo(Math.round(this.centerx + this.radius), this.centery + 5);
            
            // Draw the X check marks
            for (var i=(this.centerx - this.radius); i<(this.centerx + this.radius); i+=(this.radius / 10)) {
                co.moveTo(Math.round(i),  this.centery - 3);
                co.lineTo(Math.round(i),  this.centery + 3);
            }
            
            // Draw the Y check marks
            for (var i=(this.centery - this.radius); i<(this.centery + this.radius); i+=(this.radius / 10)) {
                co.moveTo(this.centerx - 3, Math.round(i));
                co.lineTo(this.centerx + 3, Math.round(i));
            }
        
            // Draw the Y axis
            co.moveTo(Math.round(this.centerx), this.centery - this.radius);
            co.lineTo(Math.round(this.centerx), this.centery + this.radius);
        
            // Draw the Y ends
            co.moveTo(this.centerx - 5, Math.round(this.centery - this.radius));
            co.lineTo(this.centerx + 5, Math.round(this.centery - this.radius));
        
            co.moveTo(this.centerx - 5, Math.round(this.centery + this.radius));
            co.lineTo(this.centerx + 5, Math.round(this.centery + this.radius));
            
            // Stroke it
            co.closePath();
            co.stroke();
        };




        /**
        * This method draws a set of data on the graph
        */
        this.drawRscatter =
        this.DrawRscatter = function ()
        {
            for (var dataset=0; dataset<this.data.length; dataset+=1) {

                var data              = this.data[dataset];
                this.coords2[dataset] = [];

                for (var i=0; i<data.length; ++i) {
        
                    var d1 = data[i][0];
                    var d2 = data[i][1];
                    var a   = d1 / (180 / RG.PI); // RADIANS
                    var r   = ( (d2 - prop['chart.ymin']) / (this.scale2.max - this.scale2.min) ) * this.radius;
                    var x   = Math.sin(a) * r;
                    var y   = Math.cos(a) * r;
                    var color = data[i][2] ? data[i][2] : prop['chart.colors.default'];
                    var tooltip = data[i][3] ? data[i][3] : null;
        
                    if (tooltip && String(tooltip).length) {
                        this.hasTooltips = true;
                    }
        
                    /**
                    * Account for the correct quadrant
                    */
                    x = x + this.centerx;
                    y = this.centery - y;
        
        
                    this.DrawTick(x, y, color);
                    
                    // Populate the coords array with the coordinates and the tooltip
                    this.coords.push([x, y, color, tooltip]);
                    this.coords2[dataset].push([x, y, color, tooltip]);
                }
            }
        };




        /**
        * Unsuprisingly, draws the labels
        */
        this.drawLabels =
        this.DrawLabels = function ()
        {
            co.lineWidth = 1;
            
            // Default the color to black
            co.fillStyle = 'black';
            co.strokeStyle = 'black';
            
            var key        = prop['chart.key'];
            var r          = this.radius;
            var color      = prop['chart.text.color'];
            var font       = prop['chart.text.font'];
            var size       = prop['chart.text.size'];
            var axes       = prop['chart.labels.axes'].toLowerCase();
            var units_pre  = prop['chart.units.pre'];
            var units_post = prop['chart.units.post'];
            var decimals   = prop['chart.scale.decimals'];
            var centerx    = this.centerx;
            var centery    = this.centery;
            
            co.fillStyle = prop['chart.text.color'];
    
            // Draw any labels
            if (typeof prop['chart.labels'] == 'object' && prop['chart.labels']) {
                this.DrawCircularLabels(co, prop['chart.labels'], font , size, r);
            }
    
    
            var color = 'rgba(255,255,255,0.8)';

            // Draw the axis labels
            for (var i=0,len=this.scale2.labels.length; i<len; ++i) {
                if (axes.indexOf('n') > -1) RG.Text2(this, {'tag': 'scale','font':font,'size':size,'x':centerx,'y':centery - (r * ((i+1) / len)),'text':this.scale2.labels[i],'valign':'center','halign':'center','bounding':true,'boundingFill':color});
                if (axes.indexOf('s') > -1) RG.Text2(this, {'tag': 'scale','font':font,'size':size,'x':centerx,'y':centery + (r * ((i+1) / len)),'text':this.scale2.labels[i],'valign':'center','halign':'center','bounding':true,'boundingFill':color});
                if (axes.indexOf('e') > -1) RG.Text2(this, {'tag': 'scale','font':font,'size':size,'x':centerx + (r * ((i+1) / len)),'y':centery,'text':this.scale2.labels[i],'valign':'center','halign':'center','bounding':true,'boundingFill':color});
                if (axes.indexOf('w') > -1) RG.Text2(this, {'tag': 'scale','font':font,'size':size,'x':centerx - (r * ((i+1) / len)),'y':centery,'text':this.scale2.labels[i],'valign':'center','halign':'center','bounding':true,'boundingFill':color});
            }
    
            // Draw the center minimum value (but only if there's at least one axes labels stipulated)
            if (prop['chart.labels.axes'].length > 0) {
                RG.Text2(this, {'font':font,
                                'size':size,
                                'x':centerx,
                                'y':centery,
                                'text':RG.number_format(this, Number(this.scale2.min).toFixed(this.scale2.decimals), this.scale2.units_pre, this.scale2.units_post),
                                'valign':'center',
                                'halign':'center',
                                'bounding':true,
                                'boundingFill':color,
                                'tag': 'scale'
                               });
            }
    
            /**
            * Draw the key
            */
            if (key && key.length) {
                RG.DrawKey(this, key, prop['chart.colors']);
            }
        };




        /**
        * Draws the circular labels that go around the charts
        * 
        * @param labels array The labels that go around the chart
        */
        this.drawCircularLabels =
        this.DrawCircularLabels = function (context, labels, font_face, font_size, r)
        {
            var position = prop['chart.labels.position'];
            var r        = r + 10;
    
            for (var i=0; i<labels.length; ++i) {
    
    
                var a = (360 / labels.length) * (i + 1) - (360 / (labels.length * 2));
                var a = a - 90 + (prop['chart.labels.position'] == 'edge' ? ((360 / labels.length) / 2) : 0);
    
                var x = Math.cos(a / (180/RG.PI) ) * (r + 10);
                var y = Math.sin(a / (180/RG.PI)) * (r + 10);
    
                RG.Text2(this, {'font':font_face,
                                'size':font_size,
                                'x':this.centerx + x,
                                'y':this.centery + y,
                                'text':String(labels[i]),
                                'valign':'center',
                                'halign':'center',
                                'tag': 'labels'
                               });
            }
        };




        /**
        * Draws a single tickmark
        */
        this.drawTick =
        this.DrawTick = function (x, y, color)
        {
            var tickmarks = prop['chart.tickmarks'];
            var ticksize  = prop['chart.ticksize'];
    
            co.strokeStyle = color;
            co.fillStyle   = color;
    
            // Cross
            if (tickmarks == 'cross') {
    
                co.beginPath();
                co.moveTo(x + ticksize, y + ticksize);
                co.lineTo(x - ticksize, y - ticksize);
                co.stroke();
        
                co.beginPath();
                co.moveTo(x - ticksize, y + ticksize);
                co.lineTo(x + ticksize, y - ticksize);
                co.stroke();
            
            // Circle
            } else if (tickmarks == 'circle') {
    
                co.beginPath();
                co.arc(x, y, ticksize, 0, 6.2830, false);
                co.fill();
    
            // Square
            } else if (tickmarks == 'square') {
    
                co.beginPath();
                co.fillRect(x - ticksize, y - ticksize, 2 * ticksize, 2 * ticksize);
                co.fill();
            
            // Diamond shape tickmarks
             } else if (tickmarks == 'diamond') {
    
                co.beginPath();
                    co.moveTo(x, y - ticksize);
                    co.lineTo(x + ticksize, y);
                    co.lineTo(x, y + ticksize);
                    co.lineTo(x - ticksize, y);
                co.closePath();
                co.fill();
    
            // Plus style tickmarks
            } else if (tickmarks == 'plus') {
            
                co.lineWidth = 1;
    
                co.beginPath();
                    co.moveTo(x, y - ticksize);
                    co.lineTo(x, y + ticksize);
                    co.moveTo(x - ticksize, y);
                    co.lineTo(x + ticksize, y);
                co.stroke();
            }
        };




        /**
        * This function makes it much easier to get the (if any) point that is currently being hovered over.
        * 
        * @param object e The event object
        */
        this.getShape =
        this.getPoint = function (e)
        {
            var mouseXY     = RG.getMouseXY(e);
            var mouseX      = mouseXY[0];
            var mouseY      = mouseXY[1];
            var overHotspot = false;
            var offset      = prop['chart.tooltips.hotspot']; // This is how far the hotspot extends
    
            for (var i=0,len=this.coords.length; i<len; ++i) {
            
                var x       = this.coords[i][0];
                var y       = this.coords[i][1];
                var tooltip = this.coords[i][3];
    
                if (
                    mouseX < (x + offset) &&
                    mouseX > (x - offset) &&
                    mouseY < (y + offset) &&
                    mouseY > (y - offset)
                   ) {
                   
                    var tooltip = RG.parseTooltipText(prop['chart.tooltips'], i);
    
                    return {0:this,1:x,2:y,3:i,'object':this, 'x':x, 'y':y, 'index':i, 'tooltip': tooltip};
                }
            }
        };




        /**
        * This function facilitates the installation of tooltip event listeners if
        * tooltips are defined.
        */
        this.allowTooltips =
        this.AllowTooltips = function ()
        {
            // Preload any tooltip images that are used in the tooltips
            RG.PreLoadTooltipImages(this);
    
    
            /**
            * This installs the window mousedown event listener that lears any
            * highlight that may be visible.
            */
            RG.InstallWindowMousedownTooltipListener(this);
    
    
            /**
            * This installs the canvas mousemove event listener. This function
            * controls the pointer shape.
            */
            RG.InstallCanvasMousemoveTooltipListener(this);
    
    
            /**
            * This installs the canvas mouseup event listener. This is the
            * function that actually shows the appropriate tooltip (if any).
            */
            RG.InstallCanvasMouseupTooltipListener(this);
        };




        /**
        * Each object type has its own Highlight() function which highlights the appropriate shape
        * 
        * @param object shape The shape to highlight
        */
        this.highlight =
        this.Highlight = function (shape)
        {
            // Add the new highlight
            RG.Highlight.Point(this, shape);
        };




        /**
        * The getObjectByXY() worker method. Don't call this call:
        * 
        * RGraph.ObjectRegistry.getObjectByXY(e)
        * 
        * @param object e The event object
        */
        this.getObjectByXY = function (e)
        {
            var mouseXY = RG.getMouseXY(e);
            var mouseX  = mouseXY[0];
            var mouseY  = mouseXY[1];
            var centerx = this.centerx;
            var centery = this.centery;
            var radius  = this.radius;
    
            if (
                   mouseX > (centerx - radius)
                && mouseX < (centerx + radius)
                && mouseY > (centery - radius)
                && mouseY < (centery + radius)
                ) {
    
                return this;
            }
        };




        /**
        * This function positions a tooltip when it is displayed
        * 
        * @param obj object    The chart object
        * @param int x         The X coordinate specified for the tooltip
        * @param int y         The Y coordinate specified for the tooltip
        * @param objec tooltip The tooltips DIV element
        */
        this.positionTooltip = function (obj, x, y, tooltip, idx)
        {
            var coordX     = obj.coords[tooltip.__index__][0];
            var coordY     = obj.coords[tooltip.__index__][1];
            var canvasXY   = RG.getCanvasXY(obj.canvas);
            var gutterLeft = obj.gutterLeft;
            var gutterTop  = obj.gutterTop;
            var width      = tooltip.offsetWidth;
    
            // Set the top position
            tooltip.style.left = 0;
            tooltip.style.top  = parseInt(tooltip.style.top) - 7 + 'px';
            
            // By default any overflow is hidden
            tooltip.style.overflow = '';
    
            // The arrow
            var img = new Image();
                img.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABEAAAAFCAYAAACjKgd3AAAARUlEQVQYV2NkQAN79+797+RkhC4M5+/bd47B2dmZEVkBCgcmgcsgbAaA9GA1BCSBbhAuA/AagmwQPgMIGgIzCD0M0AMMAEFVIAa6UQgcAAAAAElFTkSuQmCC';
                img.style.position = 'absolute';
                img.id = '__rgraph_tooltip_pointer__';
                img.style.top = (tooltip.offsetHeight - 2) + 'px';
            tooltip.appendChild(img);
            
            // Reposition the tooltip if at the edges:
            
            // LEFT edge
            if ((canvasXY[0] + coordX - (width / 2)) < 10) {
                tooltip.style.left = (canvasXY[0] + coordX - (width * 0.1)) + 'px';
                img.style.left = ((width * 0.1) - 8.5) + 'px';
    
            // RIGHT edge
            } else if ((canvasXY[0] + coordX + (width / 2)) > doc.body.offsetWidth) {
                tooltip.style.left = canvasXY[0] + coordX - (width * 0.9) + 'px';
                img.style.left = ((width * 0.9) - 8.5) + 'px';
    
            // Default positioning - CENTERED
            } else {
                tooltip.style.left = (canvasXY[0] + coordX - (width * 0.5)) + 'px';
                img.style.left = ((width * 0.5) - 8.5) + 'px';
            }
        };




        /**
        * This function returns the radius (ie the distance from the center) for a particular
        * value.
        * 
        * @param number value The value you want the radius for
        */
        this.getRadius = function (value)
        {
            var max = this.max;

            if (value < 0 || value > max) {
                return null;
            }
            
            var r = (value / max) * this.radius;
            
            return r;
        };




        /**
        * This allows for easy specification of gradients
        */
        this.parseColors = function ()
        {
            // Save the original colors so that they can be restored when the canvas is reset
            if (this.original_colors.length === 0) {
                this.original_colors['data'] = RG.array_clone(this.data);
                this.original_colors['chart.highlight.stroke'] = RG.array_clone(prop['chart.highlight.stroke']);
                this.original_colors['chart.highlight.fill']   = RG.array_clone(prop['chart.highlight.fill']);
                this.original_colors['chart.colors.default']   = RG.array_clone(prop['chart.colors.default']);
            }






            // Go through the data
            for (var i=0; i<this.data.length; i+=1) {
                for (var j=0,len=this.data[i].length; j<len; j+=1) {
                    this.data[i][j][2] = this.parseSingleColorForGradient(this.data[i][j][2]);
                }
            }
    
            prop['chart.highlight.stroke'] = this.parseSingleColorForGradient(prop['chart.highlight.stroke']);
            prop['chart.highlight.fill']   = this.parseSingleColorForGradient(prop['chart.highlight.fill']);
            prop['chart.colors.default']   = this.parseSingleColorForGradient(prop['chart.colors.default']);
        };




        /**
        * Use this function to reset the object to the post-constructor state. Eg reset colors if
        * need be etc
        */
        this.reset = function ()
        {
        };




        /**
        * This parses a single color value
        */
        this.parseSingleColorForGradient = function (color)
        {
            if (!color || typeof color != 'string') {
                return color;
            }

            if (color.match(/^gradient\((.*)\)$/i)) {
    
                var parts = RegExp.$1.split(':');
    
                // Create the gradient
                var grad = co.createRadialGradient(this.centerx, this.centery, 0, this.centerx, this.centery, this.radius);
    
                var diff = 1 / (parts.length - 1);
    
                grad.addColorStop(0, RG.trim(parts[0]));
    
                for (var j=1; j<parts.length; ++j) {
                    grad.addColorStop(j * diff, RG.trim(parts[j]));
                }
            }
    
            return grad ? grad : color;
        };




        /**
        * This function handles highlighting an entire data-series for the interactive
        * key
        * 
        * @param int index The index of the data series to be highlighted
        */
        this.interactiveKeyHighlight = function (index)
        {
            if (this.coords2 && this.coords2[index] && this.coords2[index].length) {
                this.coords2[index].forEach(function (value, idx, arr)
                {
                    co.beginPath();
                    co.fillStyle = prop['chart.key.interactive.highlight.chart.fill'];
                    co.arc(value[0], value[1], prop['chart.ticksize'] + 2, 0, RG.TWOPI, false);
                    co.fill();
                });
            }
        };




        /**
        * Using a function to add events makes it easier to facilitate method chaining
        * 
        * @param string   type The type of even to add
        * @param function func 
        */
        this.on = function (type, func)
        {
            if (type.substr(0,2) !== 'on') {
                type = 'on' + type;
            }
            
            this[type] = func;
    
            return this;
        };




        /**
        * This helps the Gantt reset colors when the reset function is called.
        * It handles going through the data and resetting the colors.
        */
        this.resetColorsToOriginalValues = function ()
        {
            /**
            * Copy the original colors over for single-event-per-line data
            */
            for (var i=0,len=this.original_colors['data'].length; i<len; ++i) {
                for (var j=0,len2=this.original_colors['data'][i].length; j<len2;++j) {
                    this.data[i][j][2] = RG.array_clone(this.original_colors['data'][i][j][2]);
                }
            }
        };




        /**
        * This function runs once only
        * (put at the end of the file (before any effects))
        */
        this.firstDrawFunc = function ()
        {
        };




        /**
        * Register the object
        */
        RG.Register(this);




        /**
        * This is the 'end' of the constructor so if the first argument
        * contains configuration data - handle that.
        */
        if (parseConfObjectForOptions) {
            RG.parseObjectStyleConfig(this, conf.options);
        }
    };