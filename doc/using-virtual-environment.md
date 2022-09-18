# Using the virtual environment 

1. Create the virtual environment:
    
        $ make create-venv SCADAJS_VENV_PATH=/path/to/somewhere/scadajs1
		
2. Activate and use it:

		$ export SCADAJS_VENV_PATH=/path/to/somewhere/scadajs1
        $ ./venv
        (scadajs1) $ 
		
### Using a virtual environment for all or some ScadaJS projects

Set the `SCADAJS_VENV_PATH` to `/path/to/existing/virtual-environment` and use the `./scada.js/venv` script to activate the virtual environment as usual. 

        
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

