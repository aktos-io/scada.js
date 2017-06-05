# Example Project

## Development

1. Build
2. Open your webapp via a web browser  

## 1. Build

### Linux

if you follow [aea-way](../../doc/aea-way.md):

   ```bash
   ./ui-dev.service
   ```
else, do it manually:

    * `cd {{scada directory}}`
    * run `gulp --app example --webapp showcase`
    * run `./run-development` in  `webserver` directory  

### Windows

* Navigate to `/path/to/scada.js`

* Open `git BASH`
    * `gulp --app=example --webapp=showcase`

* Go to `webserver` directory, double-click on `run-development.cmd`

## 2. Open in web browser

Go to: [http://localhost:4001/example/showcase](http://localhost:4001/example/showcase)


# Demo

Demo can be seen on: http://scadajs.surge.sh/showcase
