#!/bin/sh

# Taken from
# https://stackoverflow.com/questions/10622179/how-to-find-identify-large-commits-in-git-history

porcelain_opt="--porcelain"

usage="Usage: $(basename $0) [${porcelain_opt}]: lists the largest blob objects stored in the current VCS repository (currently GIT), sorted by decreasing size.
By default user-friendly information is returned, unless the ${porcelain_opt} is specified, in which case a terse script-friendly output is done."

porcelain=1

if [ "$1" = "${porcelain_opt}" ]; then
	porcelain=0
	shift
fi


if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameter specified.
${usage}" 1>&2

	exit 4

fi

if [ $porcelain -eq 1 ]; then

	# Short hashes, human-friendly sizes:

	(
		echo

		# Size threshold disabled:
		#echo "Listing the largest blob objects stored in the current repository, sorted by decreasing size, of at least 125kB:"

		echo "Listing the largest blob objects stored in the current repository, sorted by decreasing size:"
		echo

		# 2^20 is 1 megabyte, so 2^19 is 500 kiB, 2^18 is 250, etc.:

		git rev-list --objects --all |
			git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
			sed -n 's/^blob //p' |
			#awk '$2 >= 2^17' |
			sort --reverse --numeric-sort --key=2 |
			cut -c 1-12,41- |
			$(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest

	) | more

else

	git rev-list --objects --all |
		git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
		sed -n 's/^blob //p' |
		sort --reverse --numeric-sort --key=2

fi
