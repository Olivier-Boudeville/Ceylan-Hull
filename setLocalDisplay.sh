#!/bin/bash

echo "Setting X display to localhost ("`hostname`")"
export DISPLAY=`hostname`:0.0
