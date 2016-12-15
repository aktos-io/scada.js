# ScadaJS internals

## Directory Structure

```
...
├── README.md
├── gulpfile.ls
├── package.json
├── build (temporary build directory, may be deleted at any time)
│   └── public
│       ├── showcase.html
│       ├── showcase.js
│       ├── css
│       │   └── vendor.css
│       ├── js
│       │   └── vendor.js
│       ...
├── src
│   ├── client
│   │   ├── assets (files that are directly copied to {{ scada }}/build/public
│   │   ├── components (Ractive Components)
│   │   └── templates (Pug stuff)
│   │       ...
│   └── lib
│       ... (Libraries used in both server and browser)
└── vendor (Vendor specific js and css files, like Ractive, jQuery, Bootstrap...)
    ├── 000.jquery
    │   └── jquery-1.12.0.min.js
    ├── 000.ractive
    │   └── ractive.js
    ... (prefixes are used to determine concatenation order)
```
