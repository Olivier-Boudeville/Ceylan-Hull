#!/bin/sh

echo "Launching xchat with french settings"

export GDM_LANG=fr_FR.ISO-8859-1
export LANG=fr_FR.ISO-8859-1
xchat &

