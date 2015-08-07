# Quick Run

For a quick test:

    git clone https://github.com/ceremcem/aktos-dcs
    git clone https://github.com/ceremcem/aktos-dcs-webui-example/
    # run aktos-dcs/TESTS.md/#4 to see if installation is OK.  
    cd aktos-dcs-webui-example/
    npm install
    + open a terminal and type:

        node production/server.js

    + open another terminal and type:

        python test_message_sending/keypad_simulator.py

Then open [http://localhost:4000](http://localhost:4000) and see if the button clicks are sent to python process and analog display is changing.

# INSTALL

* install [aktos-dcs](https://github.com/ceremcem/aktos-dcs)
* install libzmq for node.zmq:

    sudo apt-get install libzmq3-dev # for libzmq 4.x

* install dependencies

    npm install


start development:

  + start server.ls via pm2:

      pm2 start process.json
      pm2 logs

  + start brunch:

      brunch watch
