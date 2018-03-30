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
PREFERENCES="modules.txt"

if [ ! -f "$DIR/$PREFERENCES" ]; then
    echo
    echo "Select Modules to Install"
    echo "-----------------------------------"

    modules="./\n./lib/dcs"
    while IFS= read -r module; do
        module_dir="$(realpath $(dirname $module))/"
        module_path_name=".${module_dir#$DIR}"
        if [[ "$module_path_name" == "./" ]]; then
            #modules="$modules\n$module_dir"
            echo "scada.js dependencies: [REQUIRED]"
        elif [[ "$module_path_name" == "./lib/dcs/" ]]; then
            #modules="$modules\n$module_path_name"
            echo "aktos-dcs dependencies: [REQUIRED]"
        else
            if prompt_yes_no " -> $module_path_name dependencies? "; then
                #echo "+++ $module_path_name"
                modules="$modules\n$module_path_name"
            fi
        fi
    done < <(find . -name "node_modules" -prune -a ! -name "node_modules" -o -name "package.json" | tac )

    echo
    echo "Saving Preferences to ./$PREFERENCES"
    echo "----------------------------------------------"
    echo -e $modules > "$DIR/$PREFERENCES"
else
    echo
    echo "Using $PREFERENCES file..."
    echo "-----------------------------------"
    cat "$DIR/$PREFERENCES"
fi

echo
echo "Installing Modules"
echo "-----------------------------------"

while IFS='' read -r module || [[ -n "$module" ]]; do
    echo " *** Installing dependencies for: \"$module\"";
    echo
    cd "$DIR/$module"
    echo "(removing package-lock.json)"
    rm package-lock.json 2> /dev/null
    echo "package-lock=false"  > .npmrc
    npm install
done < "$DIR/$PREFERENCES"
