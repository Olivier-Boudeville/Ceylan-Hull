#!/bin/sh

# Copyright (C) 2023-2023 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of Ceylan-Hull; see also Ceylan-Myriad's
# GNUmakerules-docutils.inc file that may automate its use.



usage="Usage: $(basename $0) [-h|--help] [-d|--display] PLANTUML_SPEC_FILE: generates a PNG rendering of the specified UML diagram, expected to be described based on the PlantUML syntax.

  This script expects the 'puml' (for PlantUML) file extension to be used for such diagram specification.

  For example: '$(basename $0) my_diagram.plantuml' will attempt to generate a corresponding 'my_diagram.png' image file.

  Refer to my-example.plantuml for test/guidance.

  Regarding the PlantUML tool, refer to http://plantuml.com.
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "  ${usage}"
	exit

fi


do_display=1

if [ "$1" = "-d" ] || [ "$1" = "--display" ]; then
	do_display=0
	shift
fi



java="$(which java 2>/dev/null)"

if [ ! -x "${java}" ]; then

   echo "  Error, no 'java' executable found." 1>&2
   exit 10

fi


# The symbolic link that is expected based on our conventions:
plantuml_jar="${HOME}/Software/PlantUML/plantuml-current.jar"

if [ ! -f "${plantuml_jar}" ]; then

	echo "  Error, no PlantUML jar found (no '${plantuml_jar}')." 1>&2
	exit 15

fi


source_file="$1"

if [ -z "${source_file}" ]; then

	echo "  Error, no source file specified.
${usage}" 1>&2
	exit 20

fi


if [ ! -f "${source_file}" ]; then

	echo "  Error, source file '${source_file}' not found." 1>&2
	exit 10

fi


target_file=$(echo ${source_file} | sed 's|\.puml$|.png|1')

#echo "target_file = ${target_file}"


if [ -f "${target_file}" ]; then

	echo "(removing pre-existing ${target_file})"
	/bin/rm -f "${target_file}"

fi


echo "Generating now '${target_file}' from '${source_file}'..."

# Also possible: -gui

if ! "${java}" -jar "${plantuml_jar}" "${source_file}"; then

	echo "  Error, the generation of a diagram from '${source_file}' failed." 1>&2
	exit 100

fi

echo "Generation succeeded!"

if [ $do_display -eq 0 ]; then

	viewer_name="eog"

	viewer="$(which ${viewer_name} 2>/dev/null)"

	if [ ! -x "${viewer}" ]; then

		echo "  Error, no image viewer found (no ${viewer_name})." 1>&2

		exit 120

	fi

	"${viewer}" "${target_file}"

fi
