#/bin/sh

help_short_opt="-h"
help_long_opt="--help"

usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [STARTING_DIR]: reformats all supported files recursively found from the specified starting directory if defined, otherwise from the current directory.

Notably useful when forking a repository, in order to canonicalise it as a whole in a single movement / commit, so that the next, actual changes are cleanly separated from this reformatting.

The root of Ceylan-Hull is expected to be in the current PATH.
"


if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

   echo "${usage}"
   exit 0

fi

reformatter="$(which reformat-source-file.sh 2>/dev/null)"


if [ $# -ge 2 ]; then

	echo "  Error, extra argument specified.
${usage}" 1>&2

	exit 100

fi

if [ $# -eq 0 ]; then
	target_dir="$(pwd)"
fi

if [ $# -eq 1 ]; then
	target_dir="$1"
fi

if [ ! -d "${target_dir}" ]; then

	echo "  Error, '${target_dir}' is not an existing directory.
${usage}"

	exit 110

fi

echo  "    Reformatting all source-like files found from '${target_dir}'..."

#find "${target_dir}"  \( -name "$PATTERN_ONE" -o -name "$PATTERN_TWO" \) -exec $STYLE_CONVERTER '{}' ';'

# Too long paths displayed:
#find "${target_dir}" -type f -exec "${reformatter}" '{}' ';'

cd "${target_dir}" && find . -type f -exec "${reformatter}" '{}' ';'

echo "
Once done, if appropriate, we recommend committing all these reformatting changes as a whole (e.g. from a Git root, 'git add -u . && git commit -m \"Source files reformatted as a whole for uniformity.\"') in order to better trace the actual differences that will be introduced afterwards."
