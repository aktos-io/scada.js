![ScadaJS](https://cdn.rawgit.com/aktos-io/scada.js/master/assets/scadajs-logo-long.svg)

# Description

ScadaJS is a library to easily create Single Page Web Applications, targeted to industrial distributed SCADA and MRP/ERP systems.

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
   * Supports variety of network and industrial protocol connectors, including
     * Simple JSON over TCP
     * Long Polling
     * Modbus (TCP, RTU, ...)
     * Siemens Comm
     * Omron FINS, Hostlink, etc...
     * and many others...

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
<aktos-dcs></aktos-dcs>

<h2>hello {{name}}!</h2>
<input value="{{name}}" />

<h3>Slider/progress</h3>
<slider inline value="{{x}}" />
<progress type="circle" value="{{x}}" />

<sync topic="public.name" value="{{name}}" />
<sync topic="public.hello" value="{{x}}" />
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
    
    
#### 6. Serve your webapp

Create a webserver that supports *Socket.io* and *aktos-dcs*:

```ls
require! <[ path express dcs ]>
app = express!
http = require \http .Server app
app.use "/", express.static path.resolve "./scada.js/build/your-webapp"
http.listen 4001, -> console.log "listening on *:4001"

# create a socket.io-DCS connector
new dcs.SocketIOServer http

# optionally create a TCP-DCS Connector
new TCPProxyServer port: 4002
 ```
 

#### 7. See the result

You can see `your-webapp` by opening http://localhost:4001 with any modern browser.

#### 8. Start adding your microservices

You can add any number of microservices (in any programming language that has an implementation of [aktos-dcs](https://github.com/aktos-io/aktos-dcs)) and make them communicate with eachother over the DCS network:

```ls
require! dcs: {Actor, sleep, TCPProxyClient}

class Example extends Actor
  ->
    super "My Example Microservice"
    @subscribe '**'
    @log.log "subscribed: #{@subscriptions}"

    @on \data, (msg) ~>
      @log.log "received a message: ", msg
      # do something with the message
            
  action: ->
    @log.log "#{@name} started..."
    i = 0
    <~ :lo(op) ~> 
      # do something useful here  
      @send "public.hello", {val: i++}
      <~ sleep 2000ms
      lo(op)

new Example!
new TCPProxyClient port: 4002 .login! 
```

# Projects and Companies Using ScadaJS

| Name | Description |
| ---- | ----- |
| [Template](https://github.com/aktos-io/scadajs-template) | Bare minimum example to show how to get up and running with ScadaJS. |
| [Showcase](https://github.com/aktos-io/scadajs-showcase) | Showcase for components and authentication/authorization mechanism.|
| [Aktos Electronics](https://aktos.io) | Aktos Electronics uses ScadaJS as its company website, MRP tool and the Enterprise Online SCADA Service infrastructure. |
| [Omron Tester](https://github.com/aktos-io/omron-tester) | Example app to demonstrate how to communicate with an Omron PLC. |
