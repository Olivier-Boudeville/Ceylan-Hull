#!/bin/sh

full_host=`hostname -f`

target_file="${full_host}-system-informations.rst"

echo "This script will collect system information about the platform it is executing on."


displayNewline()
{

	echo >> ${target_file}

}


displayTitle()
{

	title="$1"

	title_style="$2"

	if [ -z "${title_style}" ] ; then
		title_style="-"
	fi

	displayNewline
	echo "${title}" >> ${target_file}
	# Draws a line with specified character style of the same length below:
	echo "${title}" | tr "a-z\- A-Z0-9" "${title_style}" >> ${target_file}
	echo >> ${target_file}

}


displayCommandResult()
{

	command="$*"
	echo "The command \`\`${command}\`\` tells us::" >> ${target_file}
	echo >> ${target_file}
	# Insert two spaces to indent:
	res=`${command} 2>&1`
	if ! ${command} 1>/dev/null 2>&1 ; then
	    echo "(command failed to execute properly, output:
$res)" | sed 's|^|  |' >> ${target_file}
	else
	    ${command} | sed 's|^|  |' >> ${target_file}
	fi

	echo >> ${target_file}
	echo >> ${target_file}

}


# Erases any previous file:
echo > ${target_file}


displayTitle "System information about host ``${full_host}``" "."



# Maybe use also informations from: who



displayTitle "Distribution information"
displayCommandResult "cat /etc/lsb-release"

displayTitle "Kernel information"
displayCommandResult "uname -a"

displayTitle "Memory information"
displayCommandResult "free -tm"

displayTitle "CPU information"
displayCommandResult "cat /proc/cpuinfo"


echo "Result generated in ${target_file}."
