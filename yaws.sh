#!/bin/sh

### BEGIN INIT INFO
# Provides:          yaws
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:     S
# Default-Stop:
# Short-Description: Launch the Yaws webserver
### END INIT INFO

set -e

. /lib/lsb/init-functions

YAWSHOME=/tmp/yaws-esperide privbind -u web-srv /usr/local/bin/yaws -c /etc/yaws/yaws.conf --heart --daemon
