# Creating Virtual Environment 

> For Windows platform, follow [these instructions](./on-windows) first.

1. Install `nodeenv`:

        pip install nodeenv

2. Download (or create) your project:

        # download an existing project:
        git clone --recursive https://github.com/aktos-io/scadajs-template myproject && cd myproject

        # or create a project from scratch:
        git init myproject && cd myproject 
        git submodule add git submodule add https://github.com/aktos-io/scada.js

3. Create the virtual environment and activate it:
    
        $ cd ./scada.js
        $ make create-venv SCADAJS_VENV_PATH=/path/to/somewhere/scadajs1
        $ ./venv
        (scadajs1) $ 


4. Install the Scada.js dependencies:

        $ ./venv
        (scadajs1) $ make install-deps CONF=../dcs-modules.txt
        
# Using virtual environment from within Tmux

1. (Optional) Set the `SCADAJS_VENV_PATH` variable for the `TARGET_TMUX_SESSION`:

```bash
tmux setenv -t ${TARGET_TMUX_SESSION} 'SCADAJS_VENV_PATH' /path/to/somewhere/scadajs1
```

2. On every new pane, manually activate your virtual environment by:

```bash
$ ./scada.js/venv
(scadajs1) $ 
```

By setting the Tmux's `SCADAJS_VENV_PATH` variable, `./scada.js/venv` script uses this 
virtual environment by default. If you want to start a different virtual environment in your 
new pane: 

```bash
$ ./scada.js/venv /path/to/your/other/virtual-environment
(something) $ 
```

