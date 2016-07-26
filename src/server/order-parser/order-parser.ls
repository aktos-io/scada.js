email = require 'emailjs'


server = email.server.connect credentials =
    user: 'tel@aktos.io'
    password: ''
    host: 'smtp.zoho.com'
    ssl: yes


err, message <- server.send msg =
    from: 'Telemetry Service <tel@aktos.io>'
    to: 'CCA <ceremcem@ceremcem.net>'
    subject: 'tes mail'
    text: 'hey hey '

if err
    console.log "err", err
else
    console.log "message: ", message
