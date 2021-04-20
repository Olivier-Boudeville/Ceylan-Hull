#!/bin/sh

### BEGIN INIT INFO
# Provides: yaws
# Required-Start: $network $remote_fs $syslog
# Required-Stop:  $network $remote_fs $syslog
# Default-Start:  2 3 4 5
# Default-Stop:
# Short-Description: Launch the Yaws webserver
### END INIT INFO

set -e

. /lib/lsb/init-functions

YAWSHOME=/tmp/yaws-esperide privbind -u web-srv /usr/local/bin/yaws -c /etc/yaws/yaws.conf --heart --daemon

echo "Yaws webserver launched."