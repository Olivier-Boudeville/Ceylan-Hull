#!/bin/sh

usage="Usage: $(basename $0) ${web_root}: generates a simple HTML map with links from the available pages in specified web root."

echo

map_file="Map.html"

if [ -f "${map_file}" ]; then
	echo "
Error, a ${map_file} file already exists, remove it first." 1>&2
	exit 1
fi


web_root="$1"

if [ -z "${web_root}" ]; then
	echo "
${usage}: error, not enough parameters." 1>&2
	exit 2
fi

if [ ! -d "${web_root}" ]; then
	echo "
${usage}: error, '$1' is not a directory." 1>&2
	exit 3
fi


map_header="${web_root}/../common/Map-header.html"
map_footer="${web_root}/../common/Map-footer.html"


if [ ! -f "${map_header}" ]; then
	echo "  Error for map header, file <${map_header}> does not exist.
${usage}" 1>&2
	exit 4
fi

if [ ! -f "${map_footer}" ]; then
	echo "  Error for map header, file <${map_footer}> does not exist.
${usage}" 1>&2
	exit 5
fi


echo "Generating map file ${map_file} from ${web_root}..."

cat ${map_header} > ${map_file}

target_files=$(find ${web_root} -name '*.html' -print | grep -v index.htm | grep -v Menu)

echo "<ul>" >> ${map_file}

for f in ${target_files}; do
	echo "    <li><a href=\"$f\"> $(basename $f | sed 's|.html$||1')</a></li>" >> ${map_file}
done

echo "</ul>" >> ${map_file}

cat ${map_footer} >> ${map_file}

echo "Map generated! (in ${map_file})."
