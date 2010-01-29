#/bin/sh

USAGE="Usage: `basename $0` [<startingDirectory>]\n applies style transformation (as done by `basename $STYLE_CONVERTER`) to specified files searched from <starting directory> if defined, otherwise current directory"

STYLE_CONVERTER="styleConverter.sh"
PATTERN_ONE='*.cc'
PATTERN_TWO='*.C'


if [ $# -ne 0 ]; then
        if [ $# -ne 1 ]; then
                echo -e $USAGE
                exit 1
        fi
fi

if [ $# -eq 0 ]; then
        target=`pwd`
fi

if [ $# -eq 1 ]; then
        target=$1
fi

if [ ! -d "$target" ]; then
	echo "Error, $target is not an existing directory. $USAGE"
	exit 1
fi
 
echo  "    Applying $STYLE_CONVERTER "

find "$target"  \( -name "$PATTERN_ONE" -o -name "$PATTERN_TWO" \) -exec $STYLE_CONVERTER '{}' ';'

 
