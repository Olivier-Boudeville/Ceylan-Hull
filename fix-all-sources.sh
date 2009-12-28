#!/bin/sh

#root_dir=`pwd`/`dirname $0`/../..
root_dir=`pwd`

#echo root_dir = $root_dir

cd $root_dir
#ls
#pwd


script_name="fix-unbreakable-spaces.sh"

cleaner_script=`which ${script_name}`

if [ ! -x "${cleaner_script}" ] ; then

	echo "Error, no cleaner script found (${script_name})." 1>&2
	exit 5
	
fi


echo "Will clean all unbreakable spaces in source files from "`pwd`":"

# No way of using that filter in find, thus must be updated here and pasted
# in following find twice:
selection_filter=" -name '*.erl' -o -name '*.hrl' -o -name '*.txt' -o -name '*.rst' -o -name 'GNU*' -o -name '*.py' -o -name '*.css' -o -name '*.sh' -o -name '*.html' -o -name '*.java' -o -name '*.h' -o -name '*.cc' -o -name '*.inc' -o -name '*.am' -o -name '*.in' " 


find . -name .svn -prune -o  \( -type f -a \( -name '*.erl' -o -name '*.hrl' -o -name '*.txt' -o -name '*.rst' -o -name 'GNU*' -o -name '*.py' -o -name '*.css' -o -name '*.sh' -o -name '*.html' -o -name '*.java' -o -name '*.h' -o -name '*.cc' -o -name '*.inc' -o -name '*.am' -o -name '*.in'  \) \) -exec echo  '{}' ';'
  
  
read -p "Proceed? (a check-in must have been performed beforehand) (y/n) [n] " res

if [ "$res" = "y" ] ; then
	echo "Cleaning now..."
	
	find . -name .svn -prune -o  \( -type f -a \(  -name '*.erl' -o -name '*.hrl' -o -name '*.txt' -o -name '*.rst' -o -name 'GNU*' -o -name '*.py' -o -name '*.css' -o -name '*.sh' -o -name '*.html' -o -name '*.java' -o -name '*.h' -o -name '*.cc' -o -name '*.inc' -o -name '*.am' -o -name '*.in'  \) \) -exec ${cleaner_script} '{}' ';'

	echo "Note: the 'fix-unbreakable-spaces.sh' script might have been modified by this operation, but of course this 'fixed' version should not be committed."
	
else

	echo "(aborted)"
	
fi

