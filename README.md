![ScadaJS](src/client/assets/scadajs-text.png)

# Key features

* First-class support for [LiveScript](http://livescript.net) with Sourcemaps!
* Supports [RactiveJS](http://www.ractivejs.org/) with a custom (and optimized) component inclusion mechanizm
* Supports [Pug](https://pugjs.org) for composing static html documents and Ractive templates.
* Supports desktop apps via [ElectronJS](http://electron.atom.io/).
* Uses Distributed NoSQL database ([CouchDB](http://couchdb.apache.org/) in mind)
* Supports variety of network and industrial protocol [servers](./src/server), including
    * http
    * websockets
    * Raw TCP
    * Long Polling
    * Modbus
    * Siemens Comm
    * Omron Hostlink
    * etc...
* Fully compatible with [aktos-dcs (Python)](https://github.com/aktos-io/aktos-dcs), [aktos-dcs-cs (C# port)](https://github.com/aktos-io/aktos-dcs-cs), [aktos-dcs-node (Node.js port)](https://github.com/aktos-io/aktos-dcs-node) libraries, a message passing distributed control system library by [aktos.io](https://aktos.io).
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TDD](https://en.wikipedia.org/wiki/Test-driven_development) in mind.
* Provides build system via [Gulp](http://gulpjs.com).

# DEMO

Demo application source is [here](http://TODO) and can be seen in action here: https://aktos.io/showcase

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
    yarn

...and optionally [follow the aea-way](doc/aea-way.md).

