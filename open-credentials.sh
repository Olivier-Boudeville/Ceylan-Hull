#!/bin/bash

# (not sh, as we prefer 'read' to support a "no echo" option)


usage="Usage: $(basename $0): unlocks (decrypts) the credential file whose path is read from the user environment, and opens it. Once closed, re-locks it (with the same passphrase). See also: {lock|unlock}-credentials.sh."


crypt_tool_name="gpg"

crypt_tool="$(which ${crypt_tool_name} 2>/dev/null)"

if [ ! -x "${crypt_tool}" ]; then

	echo "  Error, no encryption tool found (no ${crypt_tool_name} found)." 1>&2
	exit 5

fi

# 'gpg --version' returns the available cipher algorithms.

shred_tool_name="shred"

shred_tool="$(which ${shred_tool_name} 2>/dev/null)"

if [ ! -x "${shred_tool}" ]; then

	echo "  Error, no shredding tool found (no $shred_tool_name)." 1>&2
	exit 10

fi


env_file="${HOME}/.ceylan-settings.etf"

if [ ! -f "${env_file}" ]; then

	echo "  Error, no environment file (${env_file}) found." 1>&2
	exit 15

fi


# Used to rely on a shell-compliant syntax, now Erlang one:
#source "${env_file}"

main_credentials_path="$(/bin/cat ${env_file} | grep -v % | grep main_credentials_path | sed 's|.*, "||1' | sed 's|" }.$||1')"


if [ -z "${main_credentials_path}" ]; then

	echo "  Error, no usable main_credentials_path key entry found in environment file (${env_file})." 1>&2
	exit 20

fi


unlocked_file="${main_credentials_path}.dat"
locked_file="${main_credentials_path}"


# Expected to be found locked:
already_unlocked=1


if [ ! -f "${locked_file}" ]; then

	if [ -f "${unlocked_file}" ]; then

		echo "  Warning: the credentials file (as defined in the main_credentials_path variable of the environment file '${env_file}') was already unlocked (its unlocked version, '${unlocked_file}', already exists, whereas its locked version, '${locked_file}', does not exist). As a result, a password (to be chosen identical to the usual one) will be requested (twice) when closing this file." 1>&2

		# This happens whenever left in a terminal, being forgotten, or closing
		# the terminal while still opened:
		#
		already_unlocked=0

	else

		echo "  Error, no credentials file (as defined in the main_credentials_path variable of the environment file '${env_file}') can be found (neither in a locked version, i.e. as '${locked_file}', nor in an unlocked version, i.e. as '${unlocked_file}')." 1>&2

		exit 25

	fi

else

	# So here the locked file exists.

	if [ -f "${unlocked_file}" ]; then

		echo "  Error, the credentials file (as defined in the main_credentials_path variable of the environment file '${env_file}') exists both in its locked version ('${locked_file}') and in its unlocked version ('${unlocked_file}'), this is abnormal." 1>&2

		exit 30

	fi

fi

# And here the unlocked file does not exist yet.

if [ $already_unlocked -eq 1 ]; then

	#echo "Unlocking credentials: from ${locked_file} to ${unlocked_file}."

	read -p  "Enter lock password:" -s passphrase

	#echo "passphrase = '${passphrase}'"

	echo

	crypt_opts="--verbose --cipher-algo=AES256 --batch --passphrase ${passphrase} --pinentry=loopback"

	# Enable read operations on the locked version:
	if ! chmod 400 "${locked_file}"; then

		echo "  Error, unable to relax permission of locked file '${locked_file}'." 1>&2
		exit 33

	fi

	#echo "crypt_opts=$crypt_opts"

	if ${crypt_tool} -d ${crypt_opts} --output ${unlocked_file} ${locked_file} 1>/dev/null 2>&1; then

		#echo "(credentials unlocked in ${unlocked_file})"
		echo "(credentials unlocked)"

		${shred_tool} --force --remove --zero "${locked_file}"
		res="$?"

		if [ ! ${res} -eq 0 ]; then

			echo "  Error, shredding of '${locked_file}' failed (code: $res), removing it." 1>&2
			/bin/rm -f "${locked_file}"

			exit 35

		fi

	else

		echo "  Error, unlocking failed (code: $res), stopping, locked file '${locked_file}' left as it is." 1>&2

		exit 40

	fi

else

	echo "(opening unlocked credentials)"

fi

#echo "Use lock-credentials.sh to perform the reverse operation."

emacsclient --create-frame "${unlocked_file}" --alternate-editor=emacs 1>/dev/null 2>&1

echo "(locking now the credentials)"

# No passphrase wanted to be specified on the command-line:
#lock-credentials.sh [{passphrase}]

${crypt_tool} -c ${crypt_opts} --output ${locked_file} ${unlocked_file} 1>/dev/null 2>/dev/null

res="$?"

unset passphrase

if [ ! ${res} -eq 0 ]; then

	echo "  Error, locking failed (code: ${res}), stopping, unlocked file '${unlocked_file}' left as it is, please lock it manually." 1>&2

	exit 45

fi


# Re-enabled read operations (more discrete, and needed by GIT to commit newer
# versions):
#
#chmod 000 "${locked_file}"
if chmod 400 "${locked_file}"; then

	#echo "(credentials locked in ${locked_file})"
	echo "(credentials locked)"
	${shred_tool} --force --remove --zero "${unlocked_file}"
	res="$?"

	if [ ! ${res} -eq 0 ]; then

		echo "  Error, shredding of '${unlocked_file}' failed (code: ${res}), removing it." 1>&2
		/bin/rm -f "${unlocked_file}"

		exit 50

	fi

else

	echo "  Error, permissions could not be changed (code: ${res}), stopping, unlocked file '${unlocked_file}' left as it is." 1>&2

	exit 55

fi
