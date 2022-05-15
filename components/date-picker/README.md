# API 

Example usage of `date-picker` component:

    date-picker(unix="{{ myUnixTime }}" display="{{ myDisplayTime }}" mode="date")

`unix`: Observed value. Time in UNIX format in seconds. If `ms` attribute is declared, it's in milliseconds

    eg: "1468575910000" for "Fri, 15 Jul 2016 09:45:10 GMT"

`display`: Value in user's local time.

    eg: "27.10.2016 13:15"
	
`button`: Sets the date-picker's appearance as a `button` instead of an `input`. 

`min-date`: Set minimum date to be picked. "now" or a valid `new Date()` value.

`mode`: "date", "time", "datetime", "year"

`inline`: Display selection popup as `inline` (always open)

JS Examples: https://jsbin.com/ruqakehefa/1/edit?html,js,output

Options:
--------------------------------------------

    type: 'datetime',     // picker type, can be 'datetime', 'date', 'time', 'month', or 'year'
    firstDayOfWeek: 0,    // day for first day column (0 = Sunday)
    constantHeight: true, // add rows to shorter months to keep day calendar height consistent (6 rows)
    today: false,         // show a 'today/now' button at the bottom of the calendar
    closable: true,       // close the popup after selecting a date/time
    monthFirst: true,     // month before day when parsing/converting date from/to text
    touchReadonly: true,  // set input to readonly on touch devices
    inline: false,        // create the calendar inline instead of inside a popup
    on: null,             // when to show the popup (defaults to 'focus' for input, 'click' for others)
    initialDate: null,    // date to display initially when no date is selected (null = now)
    startMode: false,     // display mode to start in, can be 'year', 'month', 'day', 'hour', 'minute' (false = 'day')
    minDate: null,        // minimum date/time that can be selected, dates/times before are disabled
    maxDate: null,        // maximum date/time that can be selected, dates/times after are disabled
    ampm: true,           // show am/pm in time mode
    disableYear: false,   // disable year selection mode
    disableMonth: false,  // disable month selection mode
    disableMinute: false, // disable minute selection mode
    formatInput: true,    // format the input text upon input blur and module creation
    startCalendar: null,  // jquery object or selector for another calendar that represents the start date of a date range
    endCalendar: null,    // jquery object or selector for another calendar that represents the end date of a date range
    multiMonth: 1,        // show multiple months when in 'day' mode

    // popup options ('popup', 'on', 'hoverable', and show/hide callbacks are overridden)
    popupOptions: {
      position: 'bottom left',
      lastResort: 'bottom left',
      prefer: 'opposite',
      hideOnScroll: false
    },

    text: {
      days: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
      months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
      monthsShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      today: 'Today',
      now: 'Now',
      am: 'AM',
      pm: 'PM'
    },

    formatter: {
      header: function (date, mode, settings) {
        //return a string to show on the header for the given 'date' and 'mode'
      },
      yearHeader: function (date, settings) {
        //return a string to show on the header for the given 'date' in year mode
      },
      monthHeader: function (date, settings) {
        //return a string to show on the header for the given 'date' in month mode
      },
      dayHeader: function (date, settings) {
        //return a string to show on the header for the given 'date' in day mode
      },
      hourHeader: function (date, settings) {
        //return a string to show on the header for the given 'date' in hour mode
      },
      minuteHeader: function (date, settings) {
        //return a string to show on the header for the given 'date' in minute mode
      },
      dayColumnHeader: function (day, settings) {
        //return a abbreviated day string to show above each column in day mode
      },
      datetime: function (date, settings) {
        //return a formatted string representing the date & time of 'date'
      },
      date: function (date, settings) {
        //return a formatted string representing the date of 'date'
      },
      time: function (date, settings, forCalendar) {
        //return a formatted string representing the time of 'date'
      },
      today: function (settings) {
        return settings.type === 'date' ? settings.text.today : settings.text.now;
      },
      cell: function (cell, date, cellOptions) {
        //customize the calendar cell, cellOptions is:
        //{ mode: string, adjacent: boolean, disabled: boolean, active: boolean, today: boolean }
      }
    },

    parser: {
      date: function (text, settings) {
        //return a date parsed from 'text'
      }
    },

    // callback when date changes, return false to cancel the change
    onChange: function (date, text, mode) {
    },

    // callback before show animation, return false to prevent show
    onShow: function () {
    },

    // callback after show animation
    onVisible: function () {
    },

    // callback before hide animation, return false to prevent hide
    onHide: function () {
    },

    // callback after hide animation
    onHidden: function () {
    },

    // is the given date disabled?
    isDisabled: function (date, mode) {
      return false;
    },

    selector: {
      popup: '.ui.popup',
      input: 'input',
      activator: 'input'
    },

    regExp: {
      dateWords: /[^A-Za-z\u00C0-\u024F]+/g,
      dateNumbers: /[^\d:]+/g
    },

    error: {
      popup: 'UI Popup, a required component is not included in this page',
      method: 'The method you called is not defined.'
    },

    className: {
      calendar: 'calendar',
      active: 'active',
      popup: 'ui popup',
      grid: 'ui equal width grid',
      column: 'column',
      table: 'ui celled center aligned unstackable table',
      prev: 'prev link',
      next: 'next link',
      prevIcon: 'chevron left icon',
      nextIcon: 'chevron right icon',
      link: 'link',
      cell: 'link',
      disabledCell: 'disabled',
      adjacentCell: 'adjacent',
      activeCell: 'active',
      rangeCell: 'range',
      focusCell: 'focus',
      todayCell: 'today',
      today: 'today link'
    },

    metadata: {
      date: 'date',
      focusDate: 'focusDate',
      startDate: 'startDate',
      endDate: 'endDate',
      mode: 'mode',
      monthOffset: 'monthOffset'
    }
