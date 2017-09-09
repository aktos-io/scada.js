![ScadaJS](https://cdn.rawgit.com/aktos-io/scada.js/master/assets/scadajs-logo-long.svg)

# Description

ScadaJS is a library to easily create Single Page Applications, targeted to industrial SCADA and MRP/ERP systems. Main objective of this library is to provide an integrated Distributed Control System layer which will make it possible to communicate with any type of hardware in realtime in any location (distributed), within the browser.

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
* Integrated with [aktos-dcs](https://github.com/aktos-io/aktos-dcs), a message passing library for distributed control systems, which makes ScadaJS support [microservices](https://en.wikipedia.org/wiki/Microservices) architecture out of the box.
   * Supports variety of network and industrial protocol connectors, including
     * Simple JSON over TCP
     * Long Polling
     * Modbus (TCP, RTU, ...)
     * Siemens Comm
     * Omron FINS, Hostlink, etc...
     * and many others...

   * Compatible with aktos.io hardwares, such as [Scada Gateway](https://aktos.io/scada/pdf).
   * Supports any number and type (SQL, NoSQL) of databases in a single application at the same time.
     * Provides realtime layer tools for CouchDB which helps [overcoming CouchDB limitations](https://github.com/aktos-io/aktos-dcs-node/tree/master/src/couch-dcs)

# DEMO

Demo application [source is here](https://github.com/aktos-io/scadajs-template) and can be seen in action at https://aktos.io/showcase

# Usage

You may get up and running with ScadaJS in 2 different ways:

### [OPTION: 1] Modify the template

Download [scadajs-template](https://github.com/aktos-io/scadajs-template) and edit to your needs.

### [OPTION: 2] Install from scratch

Follow the steps below to add ScadaJS into your existing project:

#### 1. Install Global Dependencies

1. Install [`NodeJs`](https://nodejs.org)
2. Install global `npm` dependencies (**as root/admin**):

        npm install -g gulp livescript@1.4.0

#### 2. Add ScadaJS Into Your Project

You can add ScadaJS to any of your existing projects:

    cd your-project
    git submodule add https://github.com/aktos-io/scada.js

#### 3. Install ScadaJS Dependencies

When you first create or clone a project that depends on ScadaJS, you need to install the ScadaJS dependencies:

    cd your-project
    ./scada.js/update.sh
    ./scada.js/install-modules.sh

#### 4. Create a webapp

1. Create the `webapps` folder which will hold all of your webapps:

       cd your-project
       mkdir webapps

2. Create `your-webapp`'s folder:

       cd webapps
       mkdir your-webapp
       cd your-webapp

3. Create an `app.js` (or `app.ls`) here with the following contents:

```js
new Ractive({
  el: 'body',
  template: RACTIVE_PREPARSE('app.pug'),
  data: {
    name: "world",
    x: 35
  }
});
```

4. Create your `app.html` (or `app.pug`) as your application template

```html
<h2>hello {{name}}!</h2>
<input value="{{name}}" />

<h3>Slider/progress</h3>
<slider inline value="{{x}}" />
<progress type="circle" value="{{x}}" />
```

4. Create an `index.html` (or `index.pug`) here with the following contents:

```html
<html>
  <head>
    <meta charset="utf-8">
    <script src="js/vendor.js"></script>
    <link rel="stylesheet" href="css/vendor.css">
  </head>
  <body>
    <h1>Loading...</h1>
    <script src="app.js"></script>
  </body>
</html>
```

#### 5. Build your webapp

You can simply build `your-webapp` with the following command:

    cd your-project/scada.js
    gulp --webapp your-webapp [--production]

#### 6. See the result

You can see `your-webapp` by opening `your-project/scada.js/build/your-webapp/index.html` with any modern browser.

#### 7. Next Steps

At this point, you will get a "hello world" application. In order to build an application that has a realtime layer, authentication support and so on, see the [showcase](https://github.com/aktos-io/scadajs-template).
