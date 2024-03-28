#!/bin/bash

for dir in */; do
    echo ""
    echo "Current Plugin: $dir"
    new_name="${dir::-1}.DISABLED"
    mv "$dir" "$new_name"
    trap "if [[ -d $new_name ]]; then mv $new_name $dir; fi" EXIT
    echo "Plugin has been disabled: $new_name"
    read -p "Please now test. Hit enter or exit to re-enable plugin and move on" confirm
    if [[ "$confirm" == "" ]]; then
        mv "$new_name" "$dir"
    fi
done

