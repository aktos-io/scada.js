var SocketPromiseHandler = require('socket-stress-test')
 
socket_handler = new SocketPromiseHandler({
     ioUrl: 'http://localhost:4000'
      , connectionInterval: 1000 // Fire one each second
      , maxConnections: 100 // Stop at having 100 connections
      , ioOptions: {
            transports: ['websocket'], // force only websocket (optional)
        }
})
 
 
socket_handler.new(function(socketTester, currentConnections) {
        // New connection comes in.
    })
    .disconnect(function(socketTester) {
        // Connection is disconnected by socket
    })
    .addEmit('joinRoom', {
          your: "data"
    }, 200) // after 200
    .addEmit('newMessage', {
        other: "data"
 
    }, 1000) // After 1000
    .run()
