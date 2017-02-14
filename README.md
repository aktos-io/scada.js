![ScadaJS](https://github.com/aktos-io/scada.js/blob/master/src/client/assets/scadajs.png)

# Key features

* First-class support for [LiveScript](http://livescript.net) with Sourcemaps!
* Supports [RactiveJS](http://ractivejs.com) with a custom (and optimized) component inclusion mechanizm
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

# INSTALL

Install all dependencies:

    git clone {{ scada }}
    cd {{ scada }}
    npm install    
    npm install -g gulp livescript@1.4.0
    
...and optionally [follow the aea-way](doc/aea-way.md).

# Running the Examples

See [`./apps/example/README.md`](./apps/example/README.md).

# Starting a New Project

## Way 1: Copy the template, rename, go: 
You can start a new project by simply copying [`./apps/template`](./apps/template) as `./apps/myproject`. 

## Way 2: Create a project layout by scratch:

1. Create your project directory (eg. `myproject`) in `{{ scada }}/apps` => `{{myproject}}`: `{{ scada }}/apps/myproject`
2. Place any README, scripts and source codes in your project directory.
3. Place your browser applications (webapps) in `{{ myproject }}/webapps` directory with the same name: `{{myproject}}/webapps/myproject`

## Run
1. Start Gulp by passing your project name as parameter: `gulp --project myproject`
2. The browser applications (`myproject.html`, `myproject.js` and `.css` files) will be created under `{{ scada }}/build/public` directory. Use your favourite modern browser to display your web application. 
