# Quick Run

For a quick test:

    sudo npm install -g livescript
    git clone https://github.com/ceremcem/aktos-dcs  # needed by test_message_sending.py
    git clone https://github.com/ceremcem/aktos-dcs-webui-example/
    cd aktos-dcs-webui-example/
    lsc server/server.ls &
    python test_message_sending/keypad_simulator.py

Then open [http://localhost:4000](http://localhost:4000) and see if the button at the top toggles in every 4 seconds and in the meanwhile, you can toggle the button and it sends the updates to the python process.

# INSTALL

install zmq for node:

sudo apt-get install libzmq3-dev # for libzmq 4.x
sudo npm install -g zmq




start development:

  + start server app via pm2:

      pm2 start process.json
      pm2 logs

  + start brunch:

      brunch watch
