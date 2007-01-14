#!/bin/sh
#
# ftponly shell : used to hinder users to log when used in /etc/passwd as 
# a shell executable.
# The problem is that it seems to prevent them from logging, too !
# Putting /bin/false does the trick.
#
#
trap "/bin/echo Sorry; exit 0" 1 2 3 4 5 6 7 10 15
#
IFS=""
Admin=olivier.boudeville@online.fr
System=Cameloparadalis
#
/bin/echo
/bin/echo "********************************************************************"
/bin/echo "    You are NOT allowed interactive access to $System."
/bin/echo
/bin/echo "     User accounts are restricted to ftp and web access."
/bin/echo
/bin/echo "  Direct questions concerning this policy to $Admin."
/bin/echo "********************************************************************"
/bin/echo
#
# C'ya
#
exit 0
