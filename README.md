![ScadaJS](https://cdn.rawgit.com/aktos-io/scada.js/master/assets/scadajs-logo-long.svg)

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
   * Supports variety of [connectors](https://github.com/aktos-io/aktos-dcs-node/tree/master/connectors), including:
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
     * EtherCAT (*planned)
     * E-mail
     * Webservice
     * SMS

   * Compatible with aktos.io hardwares, such as [Scada Gateway](https://aktos.io/scada/pdf).
   * Supports any number and type (SQL, NoSQL) of databases in a single application at the same time.
     * Provides realtime layer tools for CouchDB which helps [overcoming CouchDB limitations](https://github.com/aktos-io/aktos-dcs-node/tree/master/connectors/couch-dcs)

# DEMO

Demo application [source is here](https://github.com/aktos-io/scadajs-showcase) and can be seen in action at https://aktos.io/showcase

# Usage

You may get up and running with ScadaJS in 2 different ways:

### *EITHER:* Download and Modify The Template

Download [scadajs-template](https://github.com/aktos-io/scadajs-template), follow the instructions to setup and edit the examples according to your needs.

### *OR:* Add To Your [Existing] Project From Scratch

Follow the steps below to add ScadaJS into your [existing] project:

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
    git submodule update --init --recursive
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
require('components');

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
<aktos-dcs/> <!-- initialize dcs -->
<sync value="{{name}}" sync-topic="public.name" />
<sync value="{{x}}" sync-topic="public.hello" />
<!-- this is all you need to do to setup the realtime connection -->
<!-- rest is the pure Ractive template you already know -->

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
    <title>ScadaJS</title>
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


#### 6. Serve your webapp

Create a webserver that supports *Socket.io* and *aktos-dcs*:

```ls
require! <[ path express dcs dcs/browser ]>

# configuration
webserver-port = 4001
dcs-port = 4002

# Create an in-memory authentication database
users = dcs.as-docs do
    'public':
        # hash algorithm is: sha512 =>
        #   `echo -n "public" | sha512sum`
        passwd-hash: "
            d32997e9747b65a3ecf65b82533a4c843c4e16dd30cf371e8c81ab60a341de00051
            da422d41ff29c55695f233a1e06fac8b79aeb0a4d91ae5d3d18c8e09b8c73"
        roles:
          \guest-permissions

permissions = dcs.as-docs do
    'guest-permissions':
        rw:
            \hello.**

db = new dcs.AuthDB users, permissions

# Create a webserver and a SocketIO bridge
app = express!
http = require \http .Server app
app.use "/", express.static path.resolve "../scada.js/build/main"
http.listen webserver-port, ->
    console.log "webserver is listening on *:#{webserver-port}"

new browser.DcsSocketIOServer http, {db}

# create a TCP DCS Service
new dcs.DcsTcpServer {port: dcs-port, db}
```


#### 7. See the result

You can see `your-webapp` by opening http://localhost:4001 with any modern browser.

By default, the slider's output will be lost in the DCS space because there is
nothing that handles these messages. See the next step:

#### 8. Start adding your microservices

You can add any number of microservices (in any programming language that has an implementation of [aktos-dcs](https://github.com/aktos-io/aktos-dcs)) and make them communicate with each other over the DCS network:

```ls
# Create the test io handlers
require! 'dcs': {DcsTcpClient}
require! 'dcs/proxy-actors': {create-io-proxies}
require! 'dcs/drivers/simulator': {IoSimulatorDriver}
create-io-proxies do
    drivers: {IoSimulatorDriver}
    devices:
        hello:
            driver: 'IoSimulatorDriver'
            handles:
                there: {}

new DcsTcpClient port: 4002 .login {user: "public", password: "public"}

```

# Projects and Companies Using ScadaJS

| Name | Description |
| ---- | ----- |
| [Template](https://github.com/aktos-io/scadajs-template) | Bare minimum example to show how to get up and running with ScadaJS. |
| [Showcase](https://github.com/aktos-io/scadajs-showcase) | Showcase for components and authentication/authorization mechanism.|
| [Aktos Electronics](https://aktos.io) | Aktos Electronics uses ScadaJS as its company website, MRP tool and the Enterprise Online SCADA Service infrastructure. |
| [Omron Tester](https://github.com/aktos-io/omron-tester) | Example app to demonstrate how to communicate with an Omron PLC. |
