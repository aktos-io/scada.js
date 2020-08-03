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
        (nodeenv) $ 


4. Install the Scada.js dependencies:

        (nodeenv) $ make install-deps CONF=../dcs-modules.txt
        
5. Optional: Move your nodeenv to a central location and use it between projects:
        
        mv nodeenv/ ~/nodeenv/scadajs-1  # or anywhere you like
        echo "export SCADAJS_1_ENV="~/nodeenv/scadajs-1" >> ~/.bashrc

   > Next time you can use: `./scada.js/env`
