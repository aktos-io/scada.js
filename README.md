![ScadaJS](src/client/assets/scadajs-text.png)

# Key features

* Uses HTML for building user interfaces and supports [Pug](https://pugjs.org) for advanced usage (and sanity)
* Uses Javascript and provides first-class support for [LiveScript](http://livescript.net) (with sourcemaps)
* Uses [RactiveJS](http://www.ractivejs.org/) in the heart for templating system with a custom (and optimized) component inclusion mechanizm
* Supports desktop apps via [ElectronJS](http://electron.atom.io/).
* Uses Distributed NoSQL database ([CouchDB](http://couchdb.apache.org/) in mind)
* Supports variety of network and industrial protocol [servers](./src/server), including
    * Raw TCP
    * Long Polling
    * Modbus
    * Siemens Comm
    * Omron Hostlink
    * and many others...
* Fully compatible with [aktos-dcs (Python)](https://github.com/aktos-io/aktos-dcs), [aktos-dcs-cs (C# port)](https://github.com/aktos-io/aktos-dcs-cs), [aktos-dcs-node (Node.js port)](https://github.com/aktos-io/aktos-dcs-node) libraries, a message passing library for distributed control systems by [aktos.io](https://aktos.io).
* Fully compatible with aktos.io hardwares
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TDD](https://en.wikipedia.org/wiki/Test-driven_development) in mind.
* Provides build system via [Gulp](http://gulpjs.com).

# INSTALL

1. Install [`NodeJs`](https://nodejs.org) 
2. Install global dependencies:

        npm install -g gulp yarn livescript@1.4.0
    
# USAGE

Add ScadaJS into your project

    git init your-project
    cd your-project 
    git submodule add https://github.com/aktos-io/scada.js
    git submodule update --init --recursive
    cd scada.js
    yarn

...and optionally [follow the aea-way](doc/aea-way.md).

# DEMO

Demo application source is [here](http://TODO) and can be seen here in action: https://aktos.io/showcase

