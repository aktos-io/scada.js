# Key features

* First-class support for [LiveScript](http://livescript.net) with Sourcemaps!
* Supports [RactiveJS](http://ractivejs.com) with a [custom component mechanizm](./src/client/components)
* Supports [Pug](https://pugjs.org) for composing html documents
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
    npm install -g gulp livescript 
    sudo apt-get install libnotify-bin
    
...and optionally [follow the aea-way](doc/aea-way.md).

# Running the Examples

See [`./apps/example/README.md`](./apps/example/README.md).

# Starting a New Project

You can start a new project by simply copying [`./apps/template`](./apps/template) as `./apps/myproject` or create project layout by scratch:

=======

1. Create your project directory (eg. `myproject`) in `{{ scada }}/apps`
2. Place any README, scripts and source codes in your project directory.
3. Place your browser applications (webapps) in `{{ myproject }}/webapps` directory
4. Start Gulp by passing your project name as parameter: `gulp --project=myproject`
5. The browser applications (`.html`, `.js` and `.css` files) will be created under `{{ scada }}/build/public` directory

Directory structure is as follows:

```
{{ scada }}
├── apps
│   ├── template
│   │   ├── README.md
│   │   ├── webapps
│   │   │   └── example-page
│   │   │       ├── index.pug (the html file to be served to the client)
│   │   │       └── index.ls   (main js file (entry point))
...
```
