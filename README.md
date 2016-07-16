# Key features 

* First-class support for [LiveScript](http://livescript.net)
* Supports [Ractive.js](http://ractivejs.com) with a custom [component mechanizm](./src/client/components)
* Supports [Jade](http://jade-lang.com) for composing html documents
* Uses Distributed NoSQL database ([CouchDB](http://couchdb.apache.org/) in mind) via [PouchDB](http://pouchdb.com) and LongPolling
* Supports build system via [Gulp](http://gulpjs.com) ([in LiveScript](./gulpfile.ls))
* Supports variety of network and industrial protocol servers, including 
    * http
    * websockets
    * long-polling
    * Modbus 
    * etc... 
* Supports tools and documentation for [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) and [TTD](https://en.wikipedia.org/wiki/Test-driven_development) in mind. 
 
# TODO

* Add native cross platform desktop app support via [electron](http://electron.atom.io/)
* Add native mobile app support via [PhoneGap](http://phonegap.com/)
* Add OPC support 

# INSTALL

Install all dependencies:

    sudo npm install gulp livescript -g
    cd PROJECT_DIRECTORY
    npm install

# Development 

### Linux

```bash 
cd ./src
./webui-dev 
```

### Windows 

* Open `git BASH`
* `gulp`
* `cd src/server; lsc server.ls`
