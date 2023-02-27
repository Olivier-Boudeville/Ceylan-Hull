#!/bin/sh

echo "Launching xchat with French settings"

export GDM_LANG=fr_FR.ISO-8859-1
export LANG=fr_FR.ISO-8859-1
xchat &
