#!/bin/sh

echo "

System will shutdown now
"

read -e -p "Press Enter key to continue" value
shutdown -h now
