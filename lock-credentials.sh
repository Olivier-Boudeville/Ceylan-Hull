#!/bin/sh

usage="Usage: $(basename $0): locks (encrypts) the credential file whose path is read from the user environment. See also: unlock-credentials.sh."

# See also the open-credentials.sh integrated script.
#
# The present script is mostly useful whenever the previous one fails for any
# reason (ex: a text editor messing with the open/close detection of that
# credential file).


if [ ! $# -eq 0 ]; then

	echo "  Error, no parameter shall be specified.
${usage}" 1>&2

	exit 2

fi

crypt_tool_name="gpg"

crypt_tool="$(which ${crypt_tool_name} 2>/dev/null)"

if [ ! -x "${crypt_tool}" ]; then

	echo "  Error, no encryption tool found (no '${crypt_tool_name}')." 1>&2
	exit 10

fi

# 'gpg --version' returns the available cipher algorithms.

shred_tool_name="shred"

shred_tool="$(which ${shred_tool_name} 2>/dev/null)"

if [ ! -x "${shred_tool}" ]; then

	echo "  Error, no shredding tool found (no '${shred_tool_name}')." 1>&2
	exit 11

fi


env_file="$HOME/.ceylan-settings.txt"

if [ ! -f "${env_file}" ]; then

	echo "  Error, no environment file ('${env_file}') found." 1>&2
	exit 5

fi

main_credentials_path="$(/bin/cat ${env_file} | grep main_credentials_path | sed 's|.*, "||1' | sed 's|" }.$||1')"

if [ -z "${main_credentials_path}" ]; then

	echo "  Error, no main_credentials_path variable defined in environment file (${env_file}) found." 1>&2
	exit 6

fi


unlocked_file="${main_credentials_path}.dat"
locked_file="${main_credentials_path}"

if [ ! -f "${unlocked_file}" ]; then

	if [ -f "${locked_file}" ]; then

		echo "  Error, the credentials file (as defined in the main_credentials_path variable of the environment file '${env_file}') is already locked (its locked version, '${locked_file}', already exists, whereas its unlocked version, '${unlocked_file}', does not exist)." 1>&2
		exit 20

	fi

	echo "  Error, no credentials file (as defined in the main_credentials_path variable of the environment file '${env_file}') can be found (neither in a locked version, i.e. as '${locked_file}', nor in an unlocked version, i.e. as '${unlocked_file}')." 1>&2

	exit 21

fi

# So here the unlocked file exists.

if [ -f "${locked_file}" ]; then

	echo "  Error, the credentials file (as defined in the main_credentials_path variable of the environment file '${env_file}') exists both in its locked version ('${locked_file}') and in its unlocked version ('${unlocked_file}'), this is abnormal." 1>&2

	exit 22

fi

# And here the locked file does not exist yet.


#echo "Locking credentials: from ${unlocked_file} to ${locked_file}."


if ${crypt_tool} -c --cipher-algo=AES256 --output "${locked_file}" "${unlocked_file}" 1>/dev/null; then

	echo "(credentials locked in ${locked_file})"
	if ! ${shred_tool} --force --remove --zero "${unlocked_file}"; then

		echo "Error, shredding of '${unlocked_file}' failed, removing it." 1>&2
		/bin/rm -f "${unlocked_file}"

		exit 10

	fi

else

	echo "  Error, locking failed, stopping, unlocked file '${unlocked_file}' left as it is." 1>&2

	exit 11

fi

#echo "Use unlock-credentials.sh to perform the reverse operation."
