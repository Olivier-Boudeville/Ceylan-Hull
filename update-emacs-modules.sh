#!/bin/sh

usage="$(basename $0): updates the basic Emacs modules that we use."

# See also: Ceylan-Heavy/src/conf/environment/*.el

echo
echo " Updating emacs modules (*.el files)"
echo

# We define a subdirectory, otherwise the '(setq load-path...' will be reported
# as a problem waiting to happen:
#
emacs_conf_dir="${HOME}/.emacs.d/my-modules"

mkdir -p ${emacs_conf_dir}
cd ${emacs_conf_dir}

/bin/rm -f *.elc 2>/dev/null


update()
{

	echo
	echo "  + updating $1 from $2"

	if [ -f "$1" ]; then
		/bin/mv -f "$1" "$1.previous"
	fi

	wget "$2"

}


# Not useful anymore as our install-erlang.sh script takes care of it:
#
#echo "Note that init.el must be modified so that it references the Erlang version you are using (ex: .../lib/tools-x.y.z/emacs)."
# Fetch from the Erlang install, not from the net anymore:
#update erlang.el http://www.erlang.org/download/contrib/erlang.el
#ln -s ~/Software/Erlang/Erlang-current-install/lib/erlang/lib/tools-*/emacs/erlang.el

update flyspell http://www.emacswiki.org/emacs/download/flyspell.el

# Useless now, since done by whitespace
# (see http://www.emacswiki.org/emacs/HighlightLongLines)
# update highlight-80+

# Replacement for linum.el:
# update nlinum
# However linum.el is distributed with Emacs in versions after 22, so
# let's use it.

# Not useful enough:
# See also http://www.emacswiki.org/emacs/MoveByVisibleLineCommands
#update physical-line

# To display and fix (with F8) whitespace errors:
update whitespace http://www.emacswiki.org/emacs/download/whitespace.el

# For a correct right-mouse text search:
update acme-search http://www.emacswiki.org/emacs/download/acme-search.el
