![ScadaJS](https://github.com/aktos-io/scada.js/blob/master/src/client/assets/scadajs.png)

# Key features

* First-class support for [LiveScript](http://livescript.net) with Sourcemaps!
* Supports [RactiveJS](http://www.ractivejs.org/) with a custom (and optimized) component inclusion mechanizm
* Supports [Pug](https://pugjs.org) for composing static html documents and Ractive templates.
* Supports desktop apps via [ElectronJS](http://electron.atom.io/).
* Uses Distributed NoSQL database ([CouchDB](http://couchdb.apache.org/) in mind)
* Supports variety of network and industrial protocol [servers](./src/server), including
    * http
    * websockets
    * long-polling
    * Modbus
    * etc...
* Fully compatible with [aktos-dcs (Python)](https://github.com/aktos-io/aktos-dcs), [aktos-dcs-cs (C# port)](https://github.com/aktos-io/aktos-dcs-cs), [aktos-dcs-js (Node.js port)](https://github.com/aktos-io/aktos-dcs-js) libraries, a message passing distributed control system library by [aktos.io](https://aktos.io).
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TDD](https://en.wikipedia.org/wiki/Test-driven_development) in mind.
* Provides build system via [Gulp](http://gulpjs.com).

# DEMO

Demo page can be seen here: https://scadajs.surge.sh/showcase.html

# INSTALL

Install all dependencies:

    git clone https://github.com/aktos-io/scada.js
    cd scada.js
    yarn || npm install    
    npm install -g gulp livescript@1.4.0
    
...and optionally [follow the aea-way](doc/aea-way.md).

# Running the Examples

See [`./apps/example/README.md`](./apps/example/README.md).

# Creating a New Project

1. Create a new project by simply copying [`./apps/template`](./apps/template) as `./apps/myproject`. 
2. Start Gulp by passing your project name as parameter: `gulp --project myproject`
3. The browser applications (`myproject.html`, `myproject.js` and `.css` files) will be created under `{{ scada }}/build/public` directory. Use your favourite modern browser to display your web application. 
