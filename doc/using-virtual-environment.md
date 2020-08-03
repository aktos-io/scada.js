# Creating Virtual Environment 

1. Prerequisite: Install `nodeenv`

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
        $ ./env ./nodeenv
        (scadajs1) $ 


4. Install the Scada.js dependencies:

        (scadajs1) $ make install-deps CONF=../dcs-modules.txt
        
5. Optional: Move your nodeenv to a central location and use it between projects:
        
        mv nodeenv/ ~/nodeenv/scadajs-1  # or anywhere you like
        echo "export SCADAJS_1_ENV="~/nodeenv/scadajs-1" >> ~/.bashrc

   > Next time you can use: `./scada.js/env`

# Preparing Tmux

1. Add the following in your `~/.bashrc`:

```bash
# For Tmux VirtualEnv support
get_ts_name(){
    [[ -n $TMUX ]] && tmux list-panes -F '#{session_name}' | tr '-' '_'
}

get_var(){
    echo $(eval echo "\$${1}")
}

tmux_get_myenvvar(){
    echo $(get_var "ns_$(get_ts_name)_${1}")
}

tmux_set_envvar(){
    # tmux_set_envvar your-session-name variable-name value
    local session_name=$(echo $1 | tr '-' '_')
    local variable_name=$2
    local value=$3
    tmux setenv -g "ns_${session_name}_${variable_name}" "$value"
}

tmux_set_venv(){
    tmux_set_envvar $1 "VIRTUAL_ENV" $2
}

export -f tmux_set_venv
export -f tmux_set_envvar
export -f tmux_get_myenvvar

tmux_get_myvenv(){
    tmux_get_myenvvar "VIRTUAL_ENV"
}

# activate the virtual environment if it is declared
if [ -n "$(tmux_get_myvenv)" ]; then
    source $(tmux_get_myvenv)/bin/activate;
fi
```

2. Add the following line before launching Tmux:

```bash
tmux_set_venv your-tmux-session-name /path/to/your/venv
```
