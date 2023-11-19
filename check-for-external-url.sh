#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


DIR=$(dirname "$(readlink -f "$0")")
readarray -t array < <(find "${1:-$DIR}" -iname '*.css' -type f | xargs grep -EH '@import ur[l]' | cut -d: -f1)

if [ ${#array[@]} -eq 0 ]; then
    printf "${GREEN}Good. No file uses @import url(...)${NC}."
else
    printf "${RED}Problem:${NC} The following files are using ${YELLOW}@import url(...)${NC} which will result in error while compiling offline:\n\n"

    for i in "${array[@]}"; do
        echo " * $i"
    done
    echo 
    printf "${YELLOW}You should fix the problem.${NC}\n"
fi