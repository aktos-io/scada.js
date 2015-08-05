# Quick Run

For a quick test: 

    git clone https://github.com/ceremcem/aktos-dcs  # needed by test_message_sending.py
    git clone https://github.com/ceremcem/aktos-dcs-webui-example/
    cd aktos-dcs-webui-example/
    lsc server/server.ls &
    cd test_message_sending && python test_message_sending.py
  
Then open http://localhost:4000 and see if the button at the top toggles in every 4 seconds and in the meanwhile, you can toggle the button and it sends the updates to the python process. 

# INSTALL

install zmq for node:

sudo apt-get install libzmq3-dev # libzmq 4.x
sudo npm install -g zmq




for production:

  + start server app via pm2:

    pm2 start process.json
    pm2 logs


for development, add these:

  + start brunch for clientside development:

    npm start

  + continuously compile livescript server file into js (since we can not run livescript with pm2)

    lsc -cw server -o server
