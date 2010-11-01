#!/bin/sh

# Manages life-cycle of a Yaws server.

# Script to be run as /etc/init.d/yaws

name="Yaws server for Esperide"

PID=`ps -edf|grep beam|grep Yaws|awk '{ print $2 }'`

# Writable by web-srv:
log_file="/var/log/yaws/yaws-init-script.log"

yaws_root="/home/wondersye/Software/Yaws/Yaws-current-install"

case "$1" in

  start)
	if [ -n "$PID" ] ; then
		echo "Error, Yaws seems to be already running (as PID $PID)." 1>&2
		exit 10
	else
		echo "Starting $name (webserver will need some time before serving requests)."
		YAWSHOME=/tmp/yaws-esperide privbind -u web-srv $yaws_root/bin/yaws -c  $yaws_root/etc/yaws/yaws.conf 1>$log_file 2>&1 &
	fi
	;;

  stop)
	if [ -z "$PID" ] ; then
		echo "Error, Yaws does not seem to be running." 1>&2
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