# Aktos App

# INSTALL

Install all dependencies:

    cd {{ scada }}/apps
    git clone https://github.com/demeter-tel/demeter-app demeter
    
# Development

### Linux

To start WebUI development:

```bash
./{{ scada }}/apps/demeter/dev-ui
```

Then visit [http://localhost:4001](http://localhost:4001)

To start Embedded system development:

```bash
./{{ scada }}/apps/demeter/dev-w232
```

### Windows

* Open `git BASH`
* `gulp --project={{ project }}`
* `cd apps/demeter/webserver; lsc server.ls`
