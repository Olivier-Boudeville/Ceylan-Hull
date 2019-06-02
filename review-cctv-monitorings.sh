#!/bin/sh

usage="$(basename $0): allows to review more conveniently a set of CCTV recordings"


# VLC: echo "Use '+' to fast forward."

# Mplayer:
echo "Use '}' to fast forward."


recordings=$(/bin/ls *.mkv 2>/dev/null)

count=$(echo ${recordings} | wc -w)


echo "${count} recordings found."

for f in ${recordings} ; do

	done=1

	while [ $done -eq 1 ] ; do

		done=0

		echo " - viewing $f"

		mplayer -speed 15 $f 1>/dev/null 2>&1

		#cvlc $f 1>/dev/null

		understood=1

		while [ $understood -eq 1 ] ; do

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

			if [ $understood -eq 1 ] ; then

				echo "  Error, command not recognised." 1>&2

			fi

		done

	done

	echo

done
