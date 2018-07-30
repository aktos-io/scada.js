![ScadaJS](https://cdn.rawgit.com/aktos-io/scada.js/master/assets/images/scadajs-logo-long.svg)

# Description

ScadaJS is a library to create [Distributed](https://en.wikipedia.org/wiki/Distributed_Computing) Realtime [Webapps](https://en.wikipedia.org/wiki/Single-page_application), targeted to industrial distributed SCADA and MRP/ERP systems.

# Key features

* Uses HTML for building user interfaces and supports [Pug](https://pugjs.org) for advanced usage (and sanity)
* Uses Javascript and provides first-class support for [LiveScript](http://livescript.net) (with sourcemaps)
* Uses [RactiveJS](http://www.ractivejs.org/) in the heart for templating system.
  * Supports component based UI development.
* Supports desktop apps via [ElectronJS](http://electron.atom.io/).
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TDD](https://en.wikipedia.org/wiki/Test-driven_development).
* Provides build system via [Gulp](http://gulpjs.com).
  * Supports a mechanism for integrating 3rd party libraries easily.
* Supports cross platform development (see: [supported development platforms](./doc/supported-development-platforms.md))
* Integrated with [aktos-dcs-node](https://github.com/aktos-io/aktos-dcs-node), the NodeJS port of aktos-dcs.
   * [Microservices](https://en.wikipedia.org/wiki/Microservices) architecture is supported out of the box.
   * Supports variety of drivers and services including:
     * Modbus
     * Omron FINS, Hostlink, etc...
     * Beckhoff ADS
     * Siemens Comm
     * CouchDB
     * RaspberryPi IO
     * and many others...
   * Supports variety of [transports](https://github.com/aktos-io/aktos-dcs-node/tree/master/transports), including:
     * Serial port
     * Websockets
     * Ethernet (TCP/UDP)
     * EtherCAT (*planned*)
     * E-mail
     * Webservice
     * SMS

   * Compatible with aktos.io hardwares, such as [Scada Gateway](https://aktos.io/scada/pdf).
   * Supports any number and type (SQL, NoSQL) of databases in a single application at the same time.
     * Provides realtime layer tools for CouchDB which helps [overcoming CouchDB limitations](https://github.com/aktos-io/aktos-dcs-node/tree/master/connectors/couch-dcs)

# Usage & Live Demo

Explanation by example: See [scadajs-template](https://github.com/aktos-io/scadajs-template).

# Projects and Companies Using ScadaJS

| Name | Description |
| ---- | ----- |
| [Template](https://github.com/aktos-io/scadajs-template) | Bare minimum example to show how to get up and running with ScadaJS. |
| [Showcase](https://github.com/aktos-io/scadajs-showcase) | Showcase for components and authentication/authorization mechanism.|
| [Aktos Electronics](https://aktos.io) | Aktos Electronics uses ScadaJS as its company website, MRP tool and the Enterprise Online SCADA Service infrastructure. |
| [Omron Tester](https://github.com/aktos-io/omron-tester) | Example app to demonstrate how to communicate with an Omron PLC. |
