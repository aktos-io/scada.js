# Serve behind Nginx

In order to serve ScadaJS application behind a Nginx reverse proxy, make the
following configuration in `/etc/nginx/sites-enabled/your-site` file:

```
location = /subfolder {
        rewrite ^([^.]*[^/])$ $1/ permanent;
}
location ~ ^/subfolder/ {
        rewrite /subfolder/(.*) /$1 break;
        proxy_pass http://internal-ip:port;
        include websocket_proxy_params;
}
```

Where `/etc/nginx/websocket_proxy_params` file contains the following:

```
proxy_redirect off;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-Proto https;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_read_timeout 86400;
```
