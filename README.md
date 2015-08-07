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

* install brunch.io

    npm install -g brunch

* install pm2, the process manager

    npm install -g pm2

* install [aktos-dcs](https://github.com/ceremcem/aktos-dcs)

    see https://github.com/ceremcem/aktos-dcs/blob/master/README.md#install

* install libzmq for node.zmq:

    sudo apt-get install libzmq3-dev # for libzmq 4.x

* install other dependencies

    npm install


# Development

start development:

  npm start

optional: in order to see server.ls logs:

  npm run show-logs


optional: In order to build production code:

  make production
