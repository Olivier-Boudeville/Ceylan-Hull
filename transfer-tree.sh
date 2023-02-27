#!/bin/sh

usage="Usage: $(basename "$0") SOURCE_TREE_LOCATION TARGET_TREE_LOCATION: copies (possibly through the network) a tree existing in one location to another one, in a manner that is friendly to the merged trees (ex: not going through out-of-tree links, not duplicating the content of in-tree symlinks). Using scp instead would typically lead to have at the end non-uniquified trees out of uniquified ones."

source_tree_location="$1"


if [ -z "${source_tree_location}" ]; then

	echo -e "  Error, no source root location specified. ${usage}" 1>&2
	exit 5

 fi


# No more checking, directories can be on anoter host!

# if [ ! -d "${source_tree_location}" ]; then

#	echo -e "  Error, specified source root location ('${source_tree_location}') does not exist." 1>&2
#	exit 10

# fi


target_tree_location="$2"

if [ -z "${target_tree_location}" ]; then

	echo -e "  Error, no target root location specified. ${usage}" 1>&2
	exit 15

fi

# if [ ! -d "${target_tree_location}" ]; then

#	echo -e "  Error, specified target root location ('${target_tree_location}') does not exist." 1>&2
#	exit 20

# fi

if [ "${source_tree_location}" = "${target_tree_location}" ]; then

	echo -e "  Error, specified source and target locations are the same ('${source_tree_location}')." 1>&2
	exit 25

fi

rsync=$(which rsync 2>/dev/null)

if [ ! -x "${rsync}" ]; then

	echo -e "  Error, no rsync tool found." 1>&2

	exit 30

fi

# Possibly defined in the environment:
if [ -z "${SSH_PORT}" ]; then

	ssh_opt="ssh"

else
	ssh_opt="ssh -p ${SSH_PORT}"

fi

${rsync} -avz -e "${ssh_opt}" --safe-links "${source_tree_location}" "${target_tree_location}" && echo "  Transfer succeeded!"
