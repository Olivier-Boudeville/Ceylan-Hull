#!/bin/sh

# Created by Olivier Boudeville (olivier.boudeville@online.fr)
# 2004, January 9.

# Deprecated on 2004, January 14 so that its OSDL's counterpart does the job.

# This script will export Ceylan's website stored in CVS into the OSDL's webserver.
# This script is intended to be executed by crontab (see CVS-to-webserver.crontab).


WEB_ROOT=/home/groups/o/os/osdl/htdocs/main

cd $WEB_ROOT

cvs -d:pserver:anonymous@cvs1:/cvsroot/osdl export -Dtomorrow Ceylan/Ceylan-0.2/src/doc/web

