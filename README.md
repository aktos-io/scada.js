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

# TODO

* Add native cross platform desktop app support via [electron](http://electron.atom.io/)
* Add native mobile app support via [PhoneGap](http://phonegap.com/)
* Add OPC support

# INSTALL

Install all dependencies:

    sudo npm install gulp livescript -g
    cd PROJECT_DIRECTORY
    npm install

# Development

### Linux

To start WebUI development:

```bash
./tools/dev-ui
```

Then visit http://localhost:4001

To start Embedded system development:

```bash
./tools/dev-w232
```

### Windows

* Open `git BASH`
* `gulp`
* `cd src/server; lsc server.ls`

-----
Aktos Electronics, the Opensource Telemetry and Automation Company, Turkey.
https://aktos.io
info@aktos.io
