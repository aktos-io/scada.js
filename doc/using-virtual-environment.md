# Creating Virtual Environment 

> For Windows platform, follow [these instructions](./on-windows) first.

1. Install `nodeenv`:

        pip install nodeenv

2. Download or create the project:

        # download 
        git clone --recursive https://github.com/aktos-io/scadajs-template myproject && cd myproject

        # create 
        git init myproject && cd myproject 
        git submodule add git submodule add https://github.com/aktos-io/scada.js

3. Create the virtual environment and activate it:
    
        $ cd ./scada.js
        $ make create-venv
        $ ./venv
        (scadajs1) $ 


4. Install the Scada.js dependencies:

        (scadajs1) $ make install-deps CONF=../dcs-modules.txt
        
5. Optional: Move your nodeenv to a central location and use it between projects:
        
        mv nodeenv/ ~/nodeenv/scadajs-1  # or anywhere you like
        echo "export SCADAJS_1_ENV="~/nodeenv/scadajs-1" >> ~/.bashrc

   > Next time you can use: `./scada.js/venv`

# Preparing Tmux

1. Add the following in your `~/.profile` (or `~/.bashrc`):

```bash
# For Tmux VirtualEnv support
tmux_get_var(){
    local key=$1
    [[ -n "$TMUX" ]] && tmux showenv | awk -F= -v key="$key" '$1==key {print $2}'
}

# activate the virtual environment if it is declared
venv=$(tmux_get_var "VIRTUAL_ENV")
if [ -n "$venv" ]; then
    source $venv/bin/activate;
fi
```

2. Set the `VIRTUAL_ENV` variable for the target session:

```bash
tmux setenv -t ${SESSION_NAME} 'VIRTUAL_ENV' /path/to/virtualenv/
```

