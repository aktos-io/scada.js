# Overview

Welcome to the realtime, distributed, web-technology oriented SCADA system for Industrial usage. The SCADA system focuses on fast development and cross-platform (cross-browser and mobile) compatibility.


# Key features

* First-class support for [LiveScript](http://livescript.net)
* Supports [Ractive.js](http://ractivejs.com) with a custom [component mechanizm](./src/client/components)
* Supports [Jade](http://jade-lang.com) for composing html documents
* Uses Distributed NoSQL database ([CouchDB](http://couchdb.apache.org/) in mind) via
    * [PouchDB](http://pouchdb.com) for browser
    * [LongPolling](./src/lib/aea-embedded/long-polling.ls) for embedded (on [Espruino](http://espruino.com/))
* Supports variety of network and industrial protocol [servers](./src/server), including
    * http
    * websockets
    * long-polling
    * Modbus
    * etc...
* Fully compatible with [aktos-dcs (Python)](https://github.com/aktos-io/aktos-dcs), [aktos-dcs-cs (C# port)](https://github.com/aktos-io/aktos-dcs-cs), [aktos-dcs-js (Node.js port)](https://github.com/aktos-io/aktos-dcs-js) libraries, a message passing distributed control system library by [aktos.io](https://aktos.io).
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TTD](https://en.wikipedia.org/wiki/Test-driven_development) in mind.
* Supports build system via [Gulp](http://gulpjs.com) ([in LiveScript](./gulpfile.ls))

# INSTALL

Install all dependencies:

    git clone {{ scada }}
    sudo npm install gulp livescript -g
    cd {{ scada }}
    npm install
    
    
# Starting a New Project 

1. Create your project directory (eg. `myproject`) in `{{ scada }}/apps`
2. Place any README, scripts and source codes in this directory. 
3. Place your browser applications (webapps) in `{{ myproject }}/webapps` directory 
4. Start Gulp by passing your project name as parameter: `gulp --project=myproject`
5. The browser applications (`.html` pages) will be created under `{{ scada }}/build/public` directory 

# Directory Structure 

Directory structure is as follows:

```
{{ scada }}
├── apps
│   ├── aktos
│   │   ├── README.md
│   │   ├── my-custom-script.sh
│   │   ├── webapps
│   │   │   └── showcase
│   │   │       ├── ack-button.jade
│   │   │       ├── data-table.jade
│   │   │       ├── date-picker.jade
│   │   │       ├── example-component.jade
│   │   │       ├── flot-chart.jade
│   │   │       ├── pie-chart.jade
│   │   │       ├── search-combobox.jade
│   │   │       ├── showcase.jade
│   │   │       └── showcase.ls
│   │   └── webserver
│   │       └── server.ls
│   └── myproject 
│       ├── README.md
│       ├── ...
│       ├── webapps
│       │   └── my-web-app
│       │       ├── README.md
│       │       ├── my-web-app.jade
│       │       ├── my-web-app.ls
│       │       ├── ...
│       └── webserver
│           └── server.ls
├── build
│   ├── ...
│   └── public
│       ├── my-web-app.html
│       ├── my-web-app.js
│       ├── showcase.html
│       ├── showcase.js
│       ├── css
│       │   └── vendor.css
│       ├── js
│       │   └── vendor.js
│       └── (more assets and projects here)
├── gulpfile.ls
├── package.json
├── README.md
├── src
│   ├── client
│   │   ├── assets (directly goes to {{ scada }}/build/public
│   │   │   ├── ...
│   │   ├── components
│   │   │   ├── ...
│   │   │   ...
│   │   └── templates (Jade stuff)
│   │       ├── ...
│   │       ...
│   └── lib
│       └── ...
└── vendor
    ├── 000.jquery
    │   └── jquery-1.12.0.min.js
    └── 000.ractive
        └── ractive.js

```

# Examples 

You can start a new project by copying `./apps/aktos` as `./apps/myproject`

# TODO/ROADMAP

* Add native cross platform desktop app support via [electron](http://electron.atom.io/)
* Add native mobile app support via [PhoneGap](http://phonegap.com/)
* Add OPC support


