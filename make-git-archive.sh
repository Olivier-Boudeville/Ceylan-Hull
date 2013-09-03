#!/bin/sh

USAGE="Usage: "`basename $0`" PROJECT_DIR ARCHIVE_DIR: makes a backup (as an archived GIT bundle) of specified project directory, stored in specified archive directory"

if [ ! $# -eq 2 ] ; then

	echo "  Error, two parameters needed. 
$USAGE." 1>&2
	exit 1

fi

crypt_name="crypt.sh"

crypt_tool=`which ${crypt_name} 2>/dev/null`


if [ ! -x "$crypt_tool" ] ; then

	echo "Error, no executable crypt tool ($crypt_name) found." 1>&2
	exit 4

fi


project_dir="$1"

if [ ! -d "${project_dir}" ] ; then

	echo "  Error, a project directory must be specified (got: '$project_dir')." 1>&2
	exit 5

fi


archive_dir="$2"

if [ ! -d "$archive_dir" ] ; then

	echo "  Error, an archive directory must be specified (got: '$archive_dir')." 1>&2
	exit 10

fi


git_archive_name="${archive_dir}/`date +'%Y%m%d'`-${project_dir}.git-bundle"
final_archive_name="${archive_dir}/`date +'%Y%m%d'`-${project_dir}.git-bundle.gpg"


mkdir -p "${archive_dir}"

echo " Archiving '$project_dir' in '$final_archive_name'..."

cd "${project_dir}"

git bundle create "${git_archive_name}" --all
res=$?

if [ ! $res -eq 0 ] ; then
	
	echo "  Error, creation of the GIT bundle failed." 1>&2
	exit 15

fi

$crypt_tool "$git_archive_name" 
res=$?

if [ ! $res -eq 0 ] ; then
	
	echo "  Error, cyphering of archive failed." 1>&2
	exit 20

else

	/bin/rm -f "${git_archive_name}"
	echo "  Archive '${final_archive_name}' ready!"

fi
