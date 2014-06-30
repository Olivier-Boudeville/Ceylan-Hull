#!/bin/sh


echo
echo " Updating emacs modules (*.el files)"
echo

emacs_conf_dir="$HOME/.emacs.d"

mkdir -p $emacs_conf_dir
cd $emacs_conf_dir

/bin/rm -f *.elc 2>/dev/null


update()
{

	echo
	echo "  + updating $1 from $2"

	if [ -f "$1" ] ; then
		/bin/mv -f "$1" "$1.previous"
	fi

	wget $2

}

echo "Note that init.el must be modified so that it references the Erlang version you are using (ex: .../lib/tools-x.y.z/emacs)."
# Fetch from the Erlang install, not from the net anymore:
#update erlang.el http://www.erlang.org/download/contrib/erlang.el

update flyspell-guess http://www.emacswiki.org/emacs/download/flyspell-guess.el

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
