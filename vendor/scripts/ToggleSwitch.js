(function() {
	/**
	 * @constructor
	 */
	var ToggleSwitch = function(eCheckBox, sOnText, sOffText) 
	{
		/**
		 * @private
		 */
		this.eCheckBox = eCheckBox;

		/**
		 * @private
		 */
		this.eTrack = document.createElement('div');
		this.eTrack.className = 'ts-track ' + this.eCheckBox.className;
		this.eTrack.innerHTML = '<div class="ts-switch-container">' + 
									'<span class="ts-on-text">' + sOnText + '</span>' + 
									'<span class="ts-switch"></span>' + 
									'<span class="ts-off-text">' + sOffText + '</span>' + 
								'</div>';

		/**
		 * @private
		 */
		this.eSwitchContainer = this.eTrack.firstChild;

		/**
		 * @private
		 */
		this.eOnText = this.eSwitchContainer.firstChild;

		/**
		 * @private
		 */
		this.eSwitch = this.eOnText.nextSibling;

		/**
		 * @private
		 */
		this.eOffText = this.eSwitch.previousSibling;

		this.eTrack.addEventListener('click', this._click.bind(this), false);

		// Events for mobile devices
		this.eSwitch.addEventListener('touchend', this._touchEnd.bind(this), false);
		this.eSwitch.addEventListener('touchstart', this._touchStart.bind(this), false);
		this.eSwitch.addEventListener('touchmove', this._touchMove.bind(this), false);

		// Events for dragging on desktop devices.
		document.addEventListener('mousemove', this._mouseMove.bind(this), false);
		this.eSwitch.addEventListener('mousedown', this._mouseDown.bind(this), false);
		document.addEventListener('mouseup', this._mouseUp.bind(this), false);

		this.eCheckBox.parentNode.replaceChild(this.eTrack, this.eCheckBox);
		this.eTrack.appendChild(this.eCheckBox);

		if (this.eCheckBox.checked)
		{
			this._disableTransition();
			this._switch(true, true);
		}
	};

	ToggleSwitch.prototype = 
	{
                _previousState: false, 
		/**
		 * @private 
		 */
		_isOn: false,

		/**
		 * @private 
		 */
		_isMouseDown: false,

		/**
		 * @private
		 */
		_isDragging: false,

		// -- Public Methods --

		/**
		 * Returns TRUE if the switch is on, false otherwise.
		 * @return {boolean}
		 */
		isOn: function()
		{
			return this._isOn;
		},

		/**
		 * Switches the switch on.
		 */
		on: function()
		{
			this._switch(true);
		},

		/**
		 * Switches the switch off.
		 */
		off: function()
		{
			this._switch(false);
		},

		/**
		 * Toggle the switch to the opposite state.
		 */
		toggle: function()
		{
			(this._isOn) ? this.off() : this.on();
		},

		/**
		 * Adds a listener to listen to changes
		 */
		addListener: function(fCallback)
		{
			this.fCallback = fCallback;
		},

		// -- Private Methods --

		/**
		 * @private
		 */
		_click: function(e)
		{
			if (!this._isDragging)
			{
				this.toggle();	
			}
			this._isMouseDown = false;
			this._isDragging = false;
		},

		/**
		 * @private
		 */
		_mouseDown: function()
		{
			this._disableTransition();
			this._isMouseDown = true;
		},

		/**
		 * @private
		 */
		_mouseMove: function(e)
		{
			if (this._isMouseDown)
			{
				this._isDragging = true;
				this._pointerMove(e, e.pageX);
			}
		},

		/**
		 * @private
		 */
		_mouseUp: function(e)
		{
			if (this._isDragging)
			{
				this._snapSwitch();
			}
			
                        this._isMouseDown = false; // cca
		},

		/**
		 * @private
		 */
		_touchStart: function(e)
		{
			this._disableTransition();
			// Prevent scrolling of the window.
			e.preventDefault(); 
		},

		/**
		 * @private
		 */
		_touchMove: function(e)
		{
			if (e.touches.length == 1)
			{
				this._pointerMove(e, e.touches[0].pageX, true);
			}
		},

		/**
		 * @private
		 */
		_touchEnd: function(e)
		{
			this._snapSwitch();	
		},

		/**
		 * Called for both desktop and mobile pointing.
		 * @private
		 */
		_pointerMove: function(e, nCoordX, bPreventDefault)
		{
			var nPos = this._convertCoordToMarginLeft(nCoordX);
			var nBackgroundPos = this._convertCoordToBackgroundPosition(nCoordX);

			var maxMarginLeft = this._getMaxContainerMarginLeft();
			var minMarginLeft = this._getMinContainerMarginLeft();

			if (nPos <= minMarginLeft)
			{
				nPos = minMarginLeft;
				nBackgroundPos = this._getMinTrackBackgroundX();
			}
			else if (nPos >= maxMarginLeft)
			{
				nPos = maxMarginLeft;
				nBackgroundPos = 0;
			}

			this.eSwitchContainer.style.marginLeft = nPos + "px";
			this.eTrack.style.backgroundPosition = nBackgroundPos + "px";

			if (bPreventDefault) 
			{
				e.preventDefault();
			}
		},

		/**
		 * @private
		 */
		_disableTransition: function()
		{
			this._addClass(this.eTrack, 'no-transition');
		},

		/**
		 * @private
		 */
		_enableTransition: function()
		{
			this._removeClass(this.eTrack, 'no-transition');
		},

		/**
		 * @private
		 */
		_convertCoordToMarginLeft: function(nCoordX)
		{
			var left = this._getPosition(this.eTrack).left;
			return nCoordX - left - (-this._getMinContainerMarginLeft()) - (this.eSwitch.offsetWidth / 2);
		},

		/**
		 * @private
		 */
		_convertCoordToBackgroundPosition: function(nCoordX)
		{
			var left = this._getPosition(this.eTrack).left;
			return nCoordX - left - (-this._getMinTrackBackgroundX()) - (this.eSwitch.offsetWidth / 2);
		},

		/**
		 * @private
		 */
		_getOccupiedSpaceBeforeSwitch: function()
		{
			return this.eOnText.offsetWidth +
				(this._getPosition(this.eSwitch).left - this._getPosition(this.eOnText).left - this.eOnText.offsetWidth);
		},

		/**
		 * @private
		 */
		_getMaxContainerMarginLeft: function()
		{
			return this.eTrack.offsetWidth - this.eSwitch.offsetWidth - this._getOccupiedSpaceBeforeSwitch() - 1;
		},

		/**
		 * @private
		 */
		_getMinContainerMarginLeft: function() 
		{
			return -this._getOccupiedSpaceBeforeSwitch() - 1;
		},

		/**
		 * @private
		 */
		_getMinTrackBackgroundX: function()
		{
			return -this.eTrack.offsetWidth + this.eSwitch.offsetWidth - 1;
		},

		/**
		 * @private
		 */
		_snapSwitch: function()
		{
			var pos = parseInt(this.eSwitchContainer.style.marginLeft, 0);
			var max = this._getMaxContainerMarginLeft();
			var min = this._getMinContainerMarginLeft();

			(pos > (max + min) / 2) ? this.on() : this.off();
		},

		/**
		 * @private
		 */
		_switch: function(bEnabled, bDisableTransition)
		{
			this._isOn = bEnabled;
                        if (!bDisableTransition)
                        {
                                this._enableTransition();	
                        }

                        var nMargin = (bEnabled) ? this._getMaxContainerMarginLeft() : this._getMinContainerMarginLeft();
                        var nBackgroundPos = (bEnabled) ? 0 : this._getMinTrackBackgroundX();
                        this.eSwitchContainer.style.marginLeft = nMargin + "px";
                        this.eTrack.style.backgroundPosition = nBackgroundPos + "px 0px";
                        (bEnabled) ? this.eCheckBox.setAttribute('checked', 'checked') : this.eCheckBox.removeAttribute('checked');
                        if (this._isOn !== this._previousState)
                        {
                            if (this.fCallback) this.fCallback(bEnabled);
                        }
                        this._previousState = this._isOn; 
                        
		},

		// -- UTILITY METHODS --

		/**
		 * @private
		 */
		_getPosition: function(eEl)
		{
			var curleft = curtop = 0;
			if (eEl.offsetParent) 
			{
				do 
				{
					curleft += eEl.offsetLeft;
					curtop += eEl.offsetTop;
				} while (eEl = eEl.offsetParent);
			}
			return {left: curleft, top: curtop};
		},

		/**
		 * @private
		 */
		_removeClass: function(eEl, sClass)
		{
			var sClassName = (eEl.className) || '';
			eEl.className = sClassName.replace(new RegExp('(\\b' + sClass + '\\b)'), '').trim();
		},

		/**
		 * @private
		 */
		_addClass: function(eEl, sClass)
		{
			this._removeClass(eEl, sClass);
			eEl.className += ' ' + sClass;
		}
	};

	// Google Closure Externs.
	window['ToggleSwitch'] = ToggleSwitch;
	window['ToggleSwitch'].prototype['on'] = ToggleSwitch.prototype.on;
	window['ToggleSwitch'].prototype['isOn'] = ToggleSwitch.prototype.isOn;
	window['ToggleSwitch'].prototype['off'] = ToggleSwitch.prototype.off;
	window['ToggleSwitch'].prototype['toggle'] = ToggleSwitch.prototype.toggle;
})();