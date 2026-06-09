#!/bin/sh

editor_name="ProjectLibre"

usage="Usage: $(basename $0) [PROJECT_FILE]: runs the current planning editor, i.e. ${editor_name}, loading any specified project file.

The extension of project files is *.pod."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


if [ ! "$#" -le 1 ]; then

	echo "  Error, unexpected argument specified.
${usage}"

	exit 2

fi


install_hint="Download its archive from https://sourceforge.net/projects/projectlibre/files/ProjectLibre/projectlibre-${PL_VERSION}.tar.gz (e.g. PL_VERSION=1.9.8), then extract it with: mkdir ~/Software/ProjectLibre && mv ~/Downloads/projectlibre-${PL_VERSION}.tar.gz ~/Software/ProjectLibre && tar xvf projectlibre-${PL_VERSION}.tar.gz"


base_dir="${HOME}/Software/ProjectLibre"

if [ ! -d "${base_dir}" ]; then

	echo "  Error, no ProjectLibre base installation directory ('${base_dir}') found. ${install_hint}" 1>&2

	exit 5

fi


# Pick latest version thereof:
editor_dir="$(/bin/ls -1 -d ${HOME}/Software/ProjectLibre/projectlibre-*.*.*/ | sort | tail -n1)"


any_project_file="$1"

if [ -n "${any_project_file}" ]; then

	if [ ! -e "${any_project_file}" ]; then

		echo "  Error, no '${any_project_file}' project file found." 1>&2

		exit 7

	fi

fi



if [ -d "${editor_dir}" ]; then

	if [ -n "${any_project_file}" ]; then

		echo "  Loading '${any_project_file}', in ${editor_name} available from '${editor_dir}'."

	else

		echo "  Running ${editor_name}, available from '${editor_dir}'."

	fi

else

	echo "  Error, no ProjectLibre installation found in ${base_dir}. ${install_hint}" 1>&2

	exit 10

fi


# Not taken into account:
#export LC_ALL=fr_FR.UTF-8
#export LC_ALL=en_US.UTF-8

#export LANG=en_US.UTF-8
#export LC_MESSAGES=en_US.UTF-8


# Setting in ~/Software/ProjectLibre/projectlibre-x.y.z/projectlibre.sh, in
# JAVA_OPTS:
#
#lang_fr_opts="-Duser.language=fr -Duser.country=FR"
#lang_en_opts="-Duser.language=en -Duser.country=US"
#
# (not taken into account either, as .projectlibre/run.conf or
# ~/.java/.userPrefs/org/projectlibre1/)
#
# The right, only location is: ./com/projectlibre1/preference/prefs.xml, whose
# content could be for example:
#
#<?xml version="1.0" encoding="UTF-8" standalone="no"?>
#<!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd">
#<map MAP_XML_VERSION="1.0">
#  <entry key="externalLocalesDirectory" value=""/>
#  <entry key="locale" value="fr"/>
#  <entry key="useExternalLocales" value="true"/>
#</map>


#echo "${editor_dir}/projectlibre.sh ${any_project_file}"

"${editor_dir}/projectlibre.sh" "${any_project_file}" 1>/dev/null 2>&1 &
