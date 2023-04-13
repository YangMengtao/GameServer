#!/bin/bash

if ! dpkg-query -W -f='${Status}' git 2>/dev/null | grep -q "ok installed"; then
    echo "Error : git is not installed."
    exit 1
fi

echo "Find git continue!"