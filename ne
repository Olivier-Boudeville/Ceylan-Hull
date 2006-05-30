#!/bin/bash

EDITOR="nedit -create"

for f in $*; do
   echo "    Opening $f"
   $EDITOR "$f" 2>/dev/null &
done 

