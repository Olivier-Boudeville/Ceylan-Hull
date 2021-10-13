# This is a bash autocompletion setting script for our 'e' script.
#
# Serves so that the autocompletion filters out undesirable files (like
# generated binaries).
#
# For example, typing 'e <TAB>' will propose, as candidate, 'matrix.erl' but not
# 'matrix.beam', even if both are present in the local directory.
#
# To be executed as '. $CEYLAN_HULL/e.bash' or, better, put in the
# /etc/bash_completion.d/ directory.
#
# For example, as root:
#
# mkdir /etc/bash_completion.d && cd /etc/bash_completion.d && ln -s
# $CEYLAN_HULL/e.bash
#
# Then all new shells will adequately filter the arguments specified to 'e'.
#
# Inspiration taken from:
# - https://stackoverflow.com/questions/27045506/how-to-make-bash-completion-ignore-certain-directories
# - /usr/share/icedtea-web/etc/bash_completion.d/javaws.bash


_e()
{
	#echo "Setting autocomplete for 'e'..."
	local cur words
	cur="${COMP_WORDS[$COMP_CWORD]}"
	compopt -o filenames
	words=( $(compgen -f "$cur") )
	COMPREPLY=()
	for val in "${words[@]}" ; do
		name=$(basename "$val")
		if [[ $name == *.beam || $name == *.o ]] ; then
			continue
		fi
		COMPREPLY+=( "$val" )
	done
}

complete -F _e e
