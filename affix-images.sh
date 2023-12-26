#!/bin/sh

usage="Usage: $(basename $0) [-d|--display] IMG_TO_BE_PASTED IMG_TO_ENRICH IMG_TO_GENERATE X_OFFSET Y_OFFSET [PASTE_DIRECTION [SCALE_PASTED]]: pastes the first specified image (IMG_TO_BE_PASTED) onto the second one (IMG_TO_ENRICH), at the specified (signed) location according to the selected direction, in order to generate the third image (IMG_TO_GENERATE).
   Options are:
	-d or --display: displays the resulting generated image
	PASTE_DIRECTION is in: 'NorthWest' (the default), 'North', 'NorthEast', 'West', 'Center', 'East', 'SouthWest', 'South' and 'SouthEast'; it allows to select the direction according which the first image will be positioned within the second one; the abscissa (X) and ordinate (Y) offsets are then relative to the selected \"direction point\" (either a corner or the midpoint of a border, corresponding to the aforementioned direction); increasing (positive or negative) offsets correspond to getting closer to the center of the second image (by default directions increase from left to right, and from top to bottom)
	SCALE_PASTED determines whether the first image shall be resized before being pasted, thanks to a percentage (e.g. "50%")
   Note that the images are typically specified and requested as PNG ones, yet other formats (e.g. SVG, then with a tranparent background) can be used.
   Any already-existing resulting image file will be overwritten.
   For example:
	- to compose a detail image, once largely scaled down, onto an original image, with an offset to the left and a smaller one to the top in order to obtain a result image: $(basename $0) detail.png +15 -5 original.png res.png East 10%
	- to generate a SVG image instead: $(basename $0) detail.png +15 -5 original.png res.svg East 10%
"


do_display=1


# Process optional arguments first:

token_eaten=0

while [ $token_eaten -eq 0 ]; do

	token_eaten=1

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
	fi


	if [ "$1" = "-d" ] || [ "$1" = "--display" ]; then
		shift
		do_display=0
		token_eaten=0
	fi

done


magick="$(which magick 2>/dev/null)"

if [ ! -x "${magick}" ]; then

	echo "  Error, no 'magick' tool found." 1>&2
	exit 5

fi


# Now mandatory arguments:


img_to_be_pasted="$1"

if [ -z "${img_to_be_pasted}" ]; then

	echo "  Error, no image to be pasted specified.
${usage}" 1>&2

	exit 10

fi


if [ ! -f "${img_to_be_pasted}" ]; then

	echo "  Error, the specified image to be pasted, '${img_to_be_pasted}', does not exist.
${usage}" 1>&2

	exit 12

fi

shift


img_to_enrich="$1"

if [ -z "${img_to_enrich}" ]; then

	echo "  Error, no image to enrich specified.
${usage}" 1>&2

	exit 14

fi


if [ ! -f "${img_to_enrich}" ]; then

	echo "  Error, the specified image to enrich, '${img_to_enrich}', does not exist.
${usage}" 1>&2

	exit 16

fi

shift


img_result="$1"
shift


x="$1"
shift

y="$1"
shift

direction="$1"
shift

if [ -z "${direction}" ]; then

	direction="NorthWest"

fi


pasted_scaling="$1"
shift

if [ -z "${pasted_scaling}" ]; then

	pasted_scaling="100%"

fi




echo "Affixing '${img_to_be_pasted}' on '${img_to_enrich}' in direction '${direction}' at (${x},${y}), to result in '${img_result}'."

if ! "${magick}" "${img_to_enrich}" \( "${img_to_be_pasted}" -resize ${pasted_scaling} \) -gravity ${direction} -geometry ${x}${y} -composite "${img_result}"; then

	echo "  Error, the image generation failed." 1>&2
	exit 50

fi


if [ $do_display -eq 0 ]; then

	case "${format}" in

		"svg")
			display_exec="$(which ${svg_display} 2>/dev/null)"
			if [ ! -x "${display_exec}" ]; then

				echo "  Error, unable to display the generated SVG file: no '${svg_display}' executable found." 1>&2
				exit 50

			fi
			;;

		"png")
			display_exec="$(which ${png_display} 2>/dev/null)"
			if [ ! -x "${display_exec}" ]; then

				echo "  Error, unable to display the generated PNG file: no '${png_display}' executable found." 1>&2
				exit 55

			fi
			;;

		*)
			echo "(unexpected format)"
			exit 2
			;;

	esac

	"${display_exec}" "${img_result}" 2>/dev/null

fi
