![ScadaJS](https://cdn.rawgit.com/aktos-io/scada.js/master/assets/scadajs-logo-long.svg)

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
* Fully compatible with [aktos-dcs](https://github.com/aktos-io/aktos-dcs), a message passing library for distributed control systems by [aktos.io](https://aktos.io).
* Fully compatible with aktos.io hardwares, such as [ScadaGateway](https://aktos.io/scada/pdf)
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TDD](https://en.wikipedia.org/wiki/Test-driven_development) in mind.
* Provides build system via [Gulp](http://gulpjs.com).

# DEMO

Demo application [source is here](https://github.com/aktos-io/scadajs-template) and can be seen in action at https://aktos.io/showcase

# Usage

### 1. Install Global Dependencies 

1. Install [`NodeJs`](https://nodejs.org) 
2. Install global `npm` dependencies:

        npm install -g gulp yarn livescript@1.4.0
    
### 2. Add ScadaJS Into Your Project 

You can add ScadaJS any existing project: 

    # if there is no project yet
    git init your-project  
    
    cd your-project 
    git submodule add https://github.com/aktos-io/scada.js

### 3. Install ScadaJS Dependencies

When you first create or clone a ScadaJS project, you need to install the dependencies: 
    
    cd your-project 
    git submodule update --init --recursive
    cd scada.js
    yarn  # or `npm install`
    
    
### 4. Build Your Webapp

You can simply build your webapp: 

    cd your-project/scada.js 
    gulp --webapp your-webapp [--optimize]

In order get a complete example, take a look at the [scadajs-template](https://github.com/aktos-io/scadajs-template).

