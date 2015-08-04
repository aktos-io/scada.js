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
