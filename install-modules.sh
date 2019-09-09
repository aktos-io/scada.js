#!/bin/bash

prompt_yes_no () {
    local message=$1
    local OK_TO_CONTINUE="no"
    #>&2 echo "       ------------  YES / NO  --------------"
    while :; do
        >&2 echo -en "$message (yes/no) "
        read OK_TO_CONTINUE </dev/tty

        if [[ "${OK_TO_CONTINUE}" == "no" ]]; then
            return 1
        elif [[ "${OK_TO_CONTINUE}" == "yes" ]]; then
            return 0
        fi
        >&2 echo "Please type 'yes' or 'no' (you said: $OK_TO_CONTINUE)"
        sleep 1
    done
}

DIR=$(dirname "$(readlink -f "$0")")
PREFERENCES="dcs-modules.txt"

conf_path=${1}
if [[ -f $conf_path ]]; then
    conf_file="$conf_path"
elif [[ -d $conf_path ]]; then
    conf_file="${conf_path}/$PREFERENCES"
else
    echo "Configuration file path is required."
    exit 5
fi

if [ ! -f "$conf_file" ]; then
    echo
    echo "Select Modules to Install"
    echo "-----------------------------------"

    declare -a modules_enabled
    declare -a modules_disabled
    while IFS= read -r module; do
        module_dir="$(realpath $(dirname $module))/"
        module_path_name=".${module_dir#$DIR}"
        if [[ "$module_path_name" == "./" ]]; then
            #modules="$modules\n$module_dir"
            echo " -> scada.js dependencies: [REQUIRED]"
            modules_enabled+=("$module_path_name")
        elif [[ "$module_path_name" == "./lib/dcs/" ]]; then
            #modules="$modules\n$module_path_name"
            echo " -> aktos-dcs dependencies: [REQUIRED]"
            modules_enabled+=("$module_path_name")
        else
            if prompt_yes_no " -> $module_path_name dependencies? "; then
                #echo "+++ $module_path_name"
                modules_enabled+=("$module_path_name")
            else
                 modules_disabled+=("$module_path_name")
            fi
        fi
    done < <(find . -name "node_modules" -prune -a ! -name "node_modules" -o -name "package.json" | tac )

    echo
    echo "Saving Preferences to $conf_file"
    echo "----------------------------------------------"
    for i in "${modules_enabled[@]}"; do 
        echo -e "yes\t$i" >> $conf_file
    done
    for i in "${modules_disabled[@]}"; do 
        echo -e "no\t$i" >> $conf_file
    done
else
    echo
    echo "Using $conf_file file..."
    echo "-----------------------------------"
    cat "$conf_file"
fi



echo
echo "Installing Modules"
echo "-----------------------------------"

while IFS='' read -r module || [[ -n "$module" ]]; do
    status=$(echo $module | awk -F' ' '{print $1}')
    module=$(echo $module | awk -F' ' '{print $2}')
    if [[ "$status" = "no" ]]; then 
        echo " --- Skipping disabled module: \"$module\""
    else
        echo " *** Installing dependencies for: \"$module\"";
        echo
        cd "$DIR/$module"

        # remove package-lock.json
        echo "(removing package-lock.json)"
        rm package-lock.json 2> /dev/null
        echo "package-lock=false"  > .npmrc

        npm install
    fi
done < "$conf_file"
