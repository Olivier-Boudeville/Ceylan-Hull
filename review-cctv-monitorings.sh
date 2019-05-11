#!/bin/sh

usage="$(basename $0): allows to review more conveniently a set of CCTV recordings"


# VLC: echo "Use '+' to fast forward."

# Mplayer:
echo "Use '}' to fast forward."


for f in $(/bin/ls *.mkv 2>/dev/null) ; do

	done=1

	while [ $done -eq 1 ] ; do

		done=0

		echo " - viewing $f"

		mplayer -speed 6 $f 1>/dev/null 2>&1

		#cvlc $f 1>/dev/null

		echo "Select action: [D: Delete, R: Replay, S: Store, L: Leave as it is, S: Stop the review]"
		read answer

		if [ $answer = "d" ] || [ $answer = "D" ]; then

			/bin/rm -f "$f"
			echo "  ('$f' deleted)"

		fi

		if [ $answer = "r" ] || [ $answer = "R" ]; then

			echo "  (replaying '$f')"
			done=1

		fi


		if [ $answer = "s" ] || [ $answer = "S" ]; then

			echo "  Enter a prefix to apply to this file to store:"
			read prefix

			new_file="${HOME}/${prefix}-$f"
			/bin/mv "$f" "${new_file}"
			echo "  ('$f' stored as '${new_file}')"

		fi

		# L is automatic

		if [ $answer = "s" ] || [ $answer = "S" ]; then

			echo "  (review requested to stop)"
			exit 0

		fi

	done

	echo

done
