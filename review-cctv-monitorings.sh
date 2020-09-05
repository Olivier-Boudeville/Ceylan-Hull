#!/bin/sh

usage="Usage: $(basename $0): [-nf|--no-fetch] [-na|--no-autoplay]: allows to (possibly) fetch from server and review conveniently any set of CCTV recordings dating back from yesterday and the three days before.
  Without fetching, CCTV recordings are expected to be already available in the current directory.
  With autoplay, recordings are displayed in a row, and offered to be deleted as a whole afterwards (locally and/or on the server). Without autoplay, they are displayed one by one, the user being asked what to do with each of them in turn."

# Enabled by default:
do_fetch=0

# Enabled by default:
auto_play=0


token_eaten=0

while [ $token_eaten -eq 0 ]; do

	#[ $verbose -eq 1 ] || echo "Args: $*"

	token_eaten=1

	if [ "$1" = "-na" ] || [ "$1" = "--no-autoplay" ]; then
		echo "(autoplay disabled)"
		shift
		auto_play=1
		token_eaten=0
	fi

	if [ "$1" = "-nf" ] || [ "$1" = "--no-fetch" ]; then
		echo "(fetching disabled)"
		shift
		do_fetch=1
		token_eaten=0
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
		token_eaten=0
	fi

done

if [ ! $# -eq 0 ]; then

	echo "  Error, unexpected argument(s): '$*'." 1>&2
	echo "${usage}" 1>&2
	exit 4

fi

#echo "do_fetch = ${do_fetch}"
#echo "auto_play = ${auto_play}"

review_dir="${HOME}/cctv-recordings-to-review"


if [ $do_fetch -eq 0 ]; then

	# Typically defined in ~/.bashrc.contextual:

	if [ -z "${CCTV_SERVER}" ]; then

		echo "  Error, environment variable 'CCTV_SERVER' not defined." 1>&2
		exit 5

	fi

	if [ -z "${CCTV_BASE_PATH}" ]; then

		echo "  Error, environment variable 'CCTV_BASE_PATH' not defined." 1>&2
		exit 6

	fi

	if [ -z "${CCTV_PREFIX}" ]; then

		echo "  Error, environment variable 'CCTV_PREFIX' not defined." 1>&2
		exit 7

	fi

	if [ -z "${CCTV_USER}" ]; then

		echo "  Error, environment variable 'CCTV_USER' not defined." 1>&2
		exit 8

	fi

	scp=$(which scp)

	# SCP option:
	if [ -n "${SSH_PORT}" ]; then
		scp_opt="-P ${SSH_PORT}"
	fi

	mkdir -p "${review_dir}"

	cd "${review_dir}"

	yesterday=$(date -d '-1 day' '+%Y%m%d')
	day_minus_two=$(date -d '-2 day' '+%Y%m%d')
	day_minus_three=$(date -d '-3 day' '+%Y%m%d')
	day_minus_four=$(date -d '-4 day' '+%Y%m%d')

	echo "Fetching as user ${USER} CCTV recordings from ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH} for yesterday (i.e. ${yesterday}) and the three days before (i.e. ${day_minus_two}, ${day_minus_three} and ${day_minus_four}):"

	${scp} ${scp_opt} ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_four}*.mkv ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_three}*.mkv ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_two}*.mkv ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${yesterday}*.mkv . 2>/dev/null

	# Disabled, as returns an error as soon as there is no recording for at
	# least one of these days (which is however normal):
	#
	#if [ ! $? -eq 0 ]; then
	#
	#	echo "  Error, the fetching of CCTV recordings failed (no recording available?)." 1>&2
	#
	#	exit 15
	#
	#fi

	message="CCTV recordings have been fetched, hit Enter to review them."

	echo ${message}

	# As the fetch might have been long, notification useful:
	say.sh ${message}

	read answer

fi



# VLC: echo "Use '+' to fast forward."

# Mplayer:
echo "Use '}' to fast forward."


recordings=$(/bin/ls *.mkv 2>/dev/null)

count=$(echo ${recordings} | wc -w)


echo "${count} recordings found."

for f in ${recordings} ; do

	done=1

	while [ $done -eq 1 ]; do

		done=0

		echo " - viewing $f"

		mplayer -speed 25 $f 1>/dev/null 2>&1

		#cvlc $f 1>/dev/null

		# Deletion to happen at end, as a whole, rather than immediately:
		if [ $auto_play -eq 1 ]; then

			understood=1

			while [ $understood -eq 1 ]; do

				echo "Select action: [D: Delete, R: Replay, M: Move, L: Leave as it is, S: Stop the review]"
				read answer

				if [ "$answer" = "d" ] || [ "$answer" = "D" ]; then

					/bin/rm -f "$f"
					echo "  ('$f' deleted)"
					understood=0

				fi

				if [ "$answer" = "r" ] || [ "$answer" = "R" ]; then

					echo "  (replaying '$f')"
					understood=0
					done=1

				fi

				if [ "$answer" = "m" ] || [ "$answer" = "M" ]; then

					echo "  Enter a prefix to apply to this file to be moved:"
					read prefix

					new_file="${HOME}/${prefix}-$f"
					/bin/mv "$f" "${new_file}"
					echo "  ('$f' moved to '${new_file}')"

					understood=0

				fi

				if [ "$answer" = "l" ] || [ "$answer" = "L" ]; then

					understood=0

				fi

				if [ "$answer" = "s" ] || [ "$answer" = "S" ]; then

					echo "  (review requested to stop)"
					#(understood=0)
					exit 0

				fi

				if [ $understood -eq 1 ]; then

					echo "  Error, command not recognised." 1>&2

				fi

			done

			echo

		fi

	done

done

if [ ${auto_play} -eq 0 ] && [ -n "${recordings}" ]; then

	echo "Deleting all *local* CCTV recordings just displayed? (y/n) [y]"

	read answer

	if [ ! "$answer" = "n" ]; then

		#echo "Deleting as a whole local ${recordings}"
		echo "Deleting as a whole these local recordings."

		/bin/rm -f ${recordings} && echo "Deleted!"

		# Leaving as is the current directory (script may be launched repeatedly
		# from it):
		#
		#rmdir -p "${review_dir}" 2>/dev/null

	else

		echo "No local deletion performed."

	fi

	echo "Deleting all *remote* (on ${CCTV_SERVER}) CCTV recordings just displayed? (y/n) [y]"

	read answer

	if [ ! "$answer" = "n" ]; then

		#echo "Deleting as a whole remote ${recordings}"
		echo "Deleting as a whole these remote recordings."

		# SSH option:
		if [ -n "${SSH_PORT}" ]; then
			ssh_opt="-p ${SSH_PORT}"
		fi

		ssh=$(which ssh)

		remote_recordings=""
		for f in ${recordings}; do
			remote_recordings="${remote_recordings} ${CCTV_BASE_PATH}/$f"
		done

		${ssh} ${ssh_opt} ${CCTV_USER}@${CCTV_SERVER} /bin/rm -f ${remote_recordings}

		if [ $? -eq 0 ]; then

			echo "Deleted!"

		fi

	else

		echo "No remote deletion performed."

	fi

fi

if [ ${do_fetch} -eq 0 ]; then

	echo "Shall the displayed CCTV recordings be deleted *on the server* (i.e. on ${CCTV_SERVER})? (y/n) [n]"

	read answer

	if [ "$answer" = "y" ]; then

		echo "Deleting remote recordings."

		# SSH option:
		if [ -n "${SSH_PORT}" ]; then
			ssh_opt="-p ${SSH_PORT}"
		fi

		ssh=$(which ssh)

		${ssh} ${ssh_opt} ${CCTV_USER}@${CCTV_SERVER} /bin/rm -f ${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_three}*.mkv ${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_two}*.mkv ${CCTV_BASE_PATH}/${CCTV_PREFIX}*${yesterday}*.mkv

		if [ $? -eq 0 ]; then

			echo "Deleted!"

		fi

	else

		echo "No remote recordings deleted."

	fi

fi
