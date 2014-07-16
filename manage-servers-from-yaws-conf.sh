#!/bin/sh

USAGE="Usage: "$(basename $0)": updates logrotate configuration to take care of logs collected from Yaws'configuration file. Ensure that the 'compress' line in uncommented in logrotate configuration file."

YAWS_CONF="/usr/local/etc/yaws/yaws.conf"

if [ ! $(id -u) -eq 0 ] ; then

	echo "  Error, you must be root." 1>&2
	exit 9

fi

if [ ! -f "$YAWS_CONF" ] ; then

	echo "  Error, yaws config not found." 1>&2
	exit 10

fi

LOGROTATE_CONF="/etc/logrotate.conf"
if [ ! -f "$LOGROTATE_CONF" ] ; then

	echo "  Error, logrotate config not found." 1>&2
	exit 11

fi

AWSTATS_SCRIPT="/usr/share/awstats/tools/awstats_buildstaticpages.pl"
if [ ! -x "$AWSTATS_SCRIPT" ] ; then

	echo "  Error, no executable awstats script found." 1>&2
	exit 12

fi


AWSTATS_PROG="/var/mass-1/www/awstats/cgi-bin/awstats.pl"
if [ ! -x "$AWSTATS_PROG" ] ; then

	echo "  Error, no executable awstats program found." 1>&2
	exit 13

fi


STATS_WEB_DIR="/var/mass-1/www/awstats"
if [ ! -d "$STATS_WEB_DIR" ] ; then

	echo "  Error, no stats web directory found." 1>&2
	exit 14

fi


AWSTATS_TEMPLATE="$STATS_WEB_DIR/awstats.esperide-template.conf"
if [ ! -f "$AWSTATS_TEMPLATE" ] ; then

	echo "  Error, awstats template not found." 1>&2
	exit 15

fi


SITES=$(grep '<server' $YAWS_CONF | grep -v '#' | sed 's|^<server ||1' | sed 's|>$||1')

for S in $SITES ; do

	cat $AWSTATS_TEMPLATE | sed "s|ESPERIDE_SERVER_NAME|$S|g" > /etc/awstats/awstats.$S.conf

done


echo " + creating awstats configuration files from awstats.esperide-template.conf"


echo "" >> $LOGROTATE_CONF
echo "# Sections below were generated by the" $(basename $0) "script:" >> $LOGROTATE_CONF
echo "" >> $LOGROTATE_CONF

for S in $SITES ; do

	echo " + managing '$S'"

	mkdir -p "$STATS_WEB_DIR/$S"

	echo "" >> $LOGROTATE_CONF
	echo "# Section for '$S':" >> $LOGROTATE_CONF
	echo "/var/log/yaws/$S.access {" >> $LOGROTATE_CONF
	echo "  missingok" >> $LOGROTATE_CONF
	echo "  daily" >> $LOGROTATE_CONF
	echo "  rotate 4" >> $LOGROTATE_CONF
	echo "  prerotate" >> $LOGROTATE_CONF
	echo "    $AWSTATS_SCRIPT -update -config=$S -awstatsprog=$AWSTATS_PROG -dir=$STATS_WEB_DIR/$S 1>/dev/null" >> $LOGROTATE_CONF
	echo "  endscript" >> $LOGROTATE_CONF
	echo "  postrotate" >> $LOGROTATE_CONF
	# Needed, otherwise new logs will not be written anymore afterwards:
	echo "    /bin/rm -f /var/log/yaws/$S.access" >> $LOGROTATE_CONF
	echo "  endscript" >> $LOGROTATE_CONF
	echo " " >> $LOGROTATE_CONF
	echo "}" >> $LOGROTATE_CONF


done


echo " + creating entry for report.log"

echo "" >> $LOGROTATE_CONF
echo "# Adding entry for server log:" >> $LOGROTATE_CONF
echo "" >> $LOGROTATE_CONF

echo " /var/log/yaws/report.log {" >> $LOGROTATE_CONF
echo "  missingok" >> $LOGROTATE_CONF
echo "  daily" >> $LOGROTATE_CONF
echo "  rotate 4" >> $LOGROTATE_CONF
echo "  postrotate" >> $LOGROTATE_CONF
echo "    /bin/rm -f /var/log/yaws/report.log" >> $LOGROTATE_CONF
echo "  endscript" >> $LOGROTATE_CONF
echo " }" >> $LOGROTATE_CONF


# We then add a last pseudo-entry (designed to be executed last), to force Yaws
# being hupped and then be able again to write logs:

# This file *must* be in the same path as access logs, to ensure it will be
# processed last:
#

echo " + creating pseudo-entry for Yaws hupp"

echo "" >> $LOGROTATE_CONF
echo "# Adding pseudo-entry to trigger Yaws hupp (otherwise no more logs)" >> $LOGROTATE_CONF
echo "" >> $LOGROTATE_CONF

echo " /var/log/yaws/zzz-yaws-hupper {" >> $LOGROTATE_CONF
echo "   missingok" >> $LOGROTATE_CONF
echo "   daily" >> $LOGROTATE_CONF
echo "   rotate 4" >> $LOGROTATE_CONF
echo "   prerotate" >> $LOGROTATE_CONF
echo "	YAWSHOME=/tmp/yaws-esperide yaws -I main_esperide_server --hup" >> $LOGROTATE_CONF
echo "   endscript" >> $LOGROTATE_CONF
echo "   postrotate" >> $LOGROTATE_CONF
echo "	/bin/date > /var/log/yaws/zzz-yaws-hupper" >> $LOGROTATE_CONF
echo "   endscript" >> $LOGROTATE_CONF
echo " }" >> $LOGROTATE_CONF


# Bootstrap to trigger first logrotate:
/bin/date > /var/log/yaws/zzz-yaws-hupper


INDEX="$STATS_WEB_DIR/index.html"

echo " + recreating $INDEX"

echo "<html><title>Esperide Stats Viewer</title><body><h1>Welcome to the Esperide Stats Viewer!</h1><p>Please select the website whose statistics you want to see:<ul>" > $INDEX

for S in $SITES ; do

	echo "  <li><a href=\"$S/awstats.$S.html\">$S</a></li>" >> $INDEX

done


echo "</ul></p></body></html>" >> $INDEX

echo " Success! Run 'systemctl restart logrotate' for a basic check, then have a look at http://stats.esperide.com. One may also run 'logrotate --force /etc/logrotate.conf' and check that newer accesses are logged as expected."
