#!/bin/sh

usage="Usage: $(basename $0): clones the current, primary screen (e.g. the one of a laptop) to any external one (e.g. a LCD one), so that exactly the same content is displayed on both (same size, with no truncation)."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

if [ -n "$1" ]; then

	echo "  Error, unexpected parameter(s) specified ('$*').
${usage}"

	exit 5

fi


xrandr="$(which xrandr 2>/dev/null)"

if [ ! -x "${xrandr}" ]; then

	echo "  Error, no xrandr tool found." 1>&2
	exit 6

fi

#native_screen="LVDS-1"
#native_screen="eDP-1"

# Leading space needed, not to match 'disconnected':
native_screen=$(${xrandr} --current | grep ' connected' | grep primary | awk '{print $1}')

if [ -z "${native_screen}" ]; then

	echo "  Error, unable to determine the identifier of the current, primary screen." 1>&2

	exit 10

fi

echo "Detected native screen: '${native_screen}'."

# Interesting default:
base_res="1920x1080"

# Quite fixed:
#native_res="${base_res}"

# For example: 'eDP-1 connected primary 1920x1080+0+0 (normal...'
native_res=$(${xrandr} --current | grep ' connected' | grep primary | uniq | awk '{print $4}' | sed 's|\+.*||1')

if [ -z "${native_res}" ]; then

	echo "  Error, unable to determine the resolution of the current, primary screen." 1>&2

	exit 15

fi

if [ "${native_res}" = "(normal" ]; then

	#echo "  Error, unable to determine the resolution of the current, primary screen. Is it active?" 1>&2

	#exit 20

	echo "Warning: unable to determine the resolution of the current, primary screen. Assuming ${base_res}." 1>&2

	native_res="${base_res}"

else

	echo "Detected native resolution: '${native_res}'."

fi


#external_screen="HDMI-1"
#external_screen="VGA-3"

# Maybe --current | grep '*' | uniq would be more relevant:
external_screen=$(${xrandr} --current | grep ' connected' | grep -v "${native_screen}" | uniq | awk '{print $1}')

echo "Detected external screen: '${external_screen}'."


#external_res="1280x800"
#external_res="1920x1080"

# For example: 'HDMI-1 connected 1920x1080+0+0 (normal ...'
external_res=$(${xrandr} | grep ' connected' | grep -v ${native_screen} | awk '{print $3}' | sed 's|\+.*||1')

# Does not seem to detect which one is the primary:
#x_res=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
#y_res=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

echo "Detected external resolution: '${external_res}'."


# In the general case, native and external resolutions do not match.
#
# Often the external is better (finer), in which case we just have to apply the
# native one to it, to have a perfect clone. In this case:
#
target_res="${native_res}"
#target_res="${external_res}"

# A full example:
#xrandr --output LVDS-1 --mode 1366x768 --scale 1x1 --output VGA-1 --same-as LVDS-1 --mode 1920x1080 --scale 0.711x0.711

# Forces most settings, in order to have an exact clone:
${xrandr} --output ${native_screen} --mode ${native_res} --scale 1x1 --output ${external_screen} --same-as ${native_screen} --mode ${native_res}
