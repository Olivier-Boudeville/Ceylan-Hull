#!/bin/sh

USAGE="Usage: "`basename $0`" [-l]:
  Plays a beep to notify the user of an event
	[-l]: prefer a low-level (system) beep
	[-h]: this help
"


# Fallback low-level solution:
do_default_beep()
{

	echo "  Performing low-level default beep"

	# Obtained with 'apt-get install beep':
	#BEEPER="/usr/bin/beep"
	BEEPER=`which beep`

	if [ -x "$BEEPER" ] ; then

		$BEEPER
		$BEEPER
		$BEEPER

	else

		echo -e '\a'
		printf "\007"

		echo -e '\a'
		printf "\007"

		echo -e '\a'
		printf "\007"

	fi

}


if [ "$1" = "-h" ] ; then

	echo "$USAGE"
	exit 0

fi


if [ "$1" = "-l" ] ; then

	do_default_beep

	exit 0

fi


if [ -n "$1" ] ; then

	echo "  Error, unexpected parameter ($*).
$USAGE" 1>&2
	exit 1

fi


SCRIPT_CMD=`which play-sounds.sh`
PLAY_CMD=`which play`

ACTUAL_CMD=""


if [ -x "${SCRIPT_CMD}" ] ; then

	ACTUAL_CMD="$SCRIPT_CMD"

elif [ -x  "${PLAY_CMD}" ] ; then

	ACTUAL_CMD="${PLAY_CMD}"

fi

# A player has been found, needing also an audio file to be played:
if [ -n "${ACTUAL_CMD}" ] ; then

	ACTUAL_FILE=""

	CAND_1="/usr/share/sounds/purple/alert.wav"

	CAND_2="/usr/share/evolution/2.28/sounds/default_alarm.wav"

	CAND_3="/usr/share/sounds/k3b_success1.wav"

	if [ -f "${CAND_1}" ] ; then
		ACTUAL_FILE="${CAND_1}"

	elif [ -f "${CAND_2}" ] ; then
		ACTUAL_FILE="${CAND_2}"

	elif [ -f "${CAND_3}" ] ; then
		ACTUAL_FILE="${CAND_3}"

	fi

	if [ -z "$ACTUAL_FILE" ] ; then

		# No file found, reverting to basic beep:
		do_default_beep

	else

		#echo "Running $ACTUAL_CMD $ACTUAL_FILE"
		$ACTUAL_CMD $ACTUAL_FILE

	fi

else

	do_default_beep

fi
