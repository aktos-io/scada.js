# Overview

This webui is intended to be both a part of [aktos-dcs](https://github.com/ceremcem/aktos-dcs) project as its SCADA infrastructure and the official website of [aktos-elektronik](https://aktos-elektronik.com), The Open Source Telemetry and Automation Systems Company, Turkey. 

The webui is online at https://aktos-elektronik.com/test

# File Structure

+ **app**:  application specific directory, see brunch.io
 + **static**: applicaction specific jade/livescript/css... files 
 + **modules**: modules intended to be reused
 + **partials**: ractive partials that will be rendered into index.html
 + **assets**: contains files/folders which will be copied into $(PROJECT)/public directory
 + **templates**: jade layouts, mixins, etc. 
 + **styles**: stylesheet files
+ **vendor**: 3rd party library files, see brunch.io
+ **public**: compiled files for web server, see brunch.io
+ **server**: server application
+ **test**: test codes, see brunch.io
+ **manual-tests**: projects to test aktos-dcs infrastructure
+ **disabled**: disabled modules, partials, 3rd party libraries etc. 
+ **config.coffee**: configuration file for brunch.io
+ **package.json**: dependencies and package information file for Node.js
+ **Makefile**: includes some quick operation commands (clearer than package.json/scripts block)
+ **.kateproject**: Kate - our default IDE - project directory database file

# INSTALL

* install [aktos-dcs](https://github.com/ceremcem/aktos-dcs)

  * `cd test-folder`
  * `git clone https://github.com/ceremcem/aktos-dcs`
  * follow [installation notes](https://github.com/ceremcem/aktos-dcs/blob/master/README.md#install)

* install global dependencies: 

  * as root: `npm install -g livescript brunch pm2`
  * install libzmq-4.x
        
          sudo apt-get install libzmq3-dev  # or install from source

* clone this project and install rest of the dependencies

  * `cd test-folder`
  * clone or download this project
  * open terminal in project directory 
  * as normal user: `npm install`

# Quick start

While in project directory, 

* open a terminal and type:

        npm start

* open another terminal and type:

        python test_message_sending/keypad_simulator.py

Then open [http://localhost:4000](http://localhost:4000) and see if the button clicks are sent to python process and analog display is changing.


# Optional 

optional: in order to see server.ls logs:

    npm run show-logs


optional: In order to build production code:

    make production


