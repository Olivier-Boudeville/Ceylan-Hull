#!/bin/sh

# Manages life-cycle of our Nitrogen on Yaws server.

# Script to be run as /etc/init.d/nitrogen.

name="Nitrogen server for Esperide"

PID=`ps -edf|grep beam|grep nitrogen|awk '{ print $2 }'`

# Writable by web-srv:
log_file="/var/www/nitrogen-esperide.log"

nitrogen_root="/home/wondersye/Software/Nitrogen/nitrogen-current-installed-version"

# We have the choice between a privbind console (cannot run in the background)
# or a start than can run in the background, but only as root.

case "$1" in

  start)
	if [ -n "$PID" ] ; then
		echo "Error, Nitrogen seems to be already running (as PID $PID)." 1>&2
		exit 10
	else
		echo "Starting $name (webserver will need some time before serving requests)."
		# Using here 'console', since 'start' does not work apparently:

		# Works, but will not detach from terminal:
		# YAWSHOME=/tmp/nitrogen-esperide privbind -u web-srv
		#$nitrogen_root/bin/nitrogen console 1>$log_file 2>&1 &

		# Works also, but remains root:
		$nitrogen_root/bin/nitrogen start 1>$log_file 2>&1 &

	fi
	;;

  stop)
	if [ -z "$PID" ] ; then
		echo "Error, Nitrogen does not seem to be running." 1>&2
		exit 15
	else
		echo "Stopping $name, killing PID $PID."
		kill $PID
	fi
	;;

  restart)
	echo "Restarting $name."
	$0 stop
	$0 start
	;;

  reload|force-reload)
	echo "Reloading $name."
	$0 restart
	;;

  status)
	if [ -z "$PID" ] ; then
		echo "$name does not seem to run."
	else
		echo "$name is running."
	fi
	;;

  force-stop)
	echo "Force stopping $name."
	$0 stop
	;;

  *)
	echo "Usage: $0 {start|stop|restart|reload|status|force-stop}"
	exit 1
	;;

esac

exit 0