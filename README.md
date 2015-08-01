for production: 

  + start server app via pm2: 

    pm2 start process.json 


for development, add these: 

  + start brunch for clientside development: 
    
    npm start 
      
  + continuously compile livescript server file into js (since we can not run livescript with pm2)

    cd server && lsc -cw server

    
    