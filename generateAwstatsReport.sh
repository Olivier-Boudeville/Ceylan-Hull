#!/bin/sh

# Commented out to avoid having mail sent by logrotate then cron:
#echo "Generating awstats report"

report_dir="/var/www/awstats"

report_log="${report_dir}/latest-awstats-generation.log"


{

	echo "Generation began at "`date`

	# Must already exist, for appropriate permissions to be set:
	if [ ! -d "${report_dir}" ] ; then

		echo "Error, report directory not available." 1>&2
		exit 10

	fi

	cd ${report_dir}

	echo "  + scanning logs"
	
	perl /usr/local/awstats/wwwroot/cgi-bin/awstats.pl -config=esperide.com -update

	perl /usr/local/awstats/wwwroot/cgi-bin/awstats.pl -config=ftp.esperide.com -update


	echo "  + generating web pages for webserver report"
	perl /usr/local/awstats/tools/awstats_buildstaticpages.pl --awstatsprog=/usr/local/awstats/wwwroot/cgi-bin/awstats.pl -config=esperide.com > awstats.esperide.com.html

	ln -sf awstats.esperide.com.html index.html

	echo "  + full awstats webserver report available at http://stats.esperide.com"


	perl /usr/local/awstats/tools/awstats_buildstaticpages.pl --awstatsprog=/usr/local/awstats/wwwroot/cgi-bin/awstats.pl -config=ftp.esperide.com > awstats.ftp.esperide.com.html

	ln -sf awstats.ftp.esperide.com.html ftp.html

	echo "  + full awstats FTP server report available at http://stats.esperide.com/ftp.html"

	echo "... generation finished at "`date`
	
} 2>&1 > ${report_log}

