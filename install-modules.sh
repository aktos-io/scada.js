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


echo
echo "Select Modules to Install"
echo "-----------------------------------"

modules=
while IFS= read -r module; do
    module_dir=$(realpath $(dirname $module))
    module_path_name="${module_dir#"$DIR/"}"
    if [[ "$module_path_name" == "$DIR" ]]; then
        modules="$modules:$module_dir"
        echo "scada.js dependencies: [REQUIRED]"
    elif [[ "$module_path_name" == "lib/dcs" ]]; then
        modules="$modules:$module_dir"
        echo "aktos-dcs dependencies: [REQUIRED]"
    else
        if prompt_yes_no " -> $module_path_name dependencies? "; then
            #echo "+++ $module_path_name"
            modules="$modules:$module_dir"
        fi
    fi
done < <(find . -name "node_modules" -prune -a ! -name "node_modules" -o -name "package.json" | tac )

echo
echo "Installing Modules"
echo "-----------------------------------"

for module in `echo "$modules" | grep -o -e "[^:]*"`; do
    echo
    echo " *** Installing dependencies for: \"$module\"";
    echo
    cd $module
    npm install
done
