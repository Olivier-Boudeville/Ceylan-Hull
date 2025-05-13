#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-l|--low-profile] [-c|--clean-system-caches] [-e|--even-ignored]: updates the current distribution, and traces it.

 Options (order must be respected):
   - '-l' / '--low-profile': low-profile mode, no output if no error, and, in case of error, returning only a low-profile error message (suitable for a crontab, whose output is sent through an aggressively spam-filtering email system)
   - '-c' / '--clean-system-caches': cleans all system caches systematically, typically to try to save some space from /var/cache or to provide a workaround to some errors
   - '-e' / '--even-ignored': updates all packages, even the ones that were declared to be ignored (in /etc/pacman.conf); useful for pre-shutdown updates of kernels, graphical drivers, etc.; note however that using this option is not recommended, as this could synchronise for the worst the stable and LTS versions of the kernel (then they may suffer from any ongoing issue)


 Example of crontab lines:
# Each day at 2:17 AM, update the distro:
17  02   *   *  * /usr/local/bin/update-distro.sh --low-profile --clean-system-caches

 Supported distributions: Arch, previously Debian.
"


# Many problems with Haskell:

#pacman -Rsc pandoc
#pacman -Syu pandoc
#pacman -Su --ignore=ghc
#pacman -Rsdd haskell-fail



clean_caches()
{

	clean_script="clean-system-caches.sh"

	# To have Ceylan-Hull in the PATH:
	clean_script_path="$(PATH=$(dirname $0):${PATH} which ${clean_script})"

	if [ ! -x "${clean_script_path}" ]; then

		echo "  Error, the script to clean system caches ('${clean_script}') could not be found." 1>&2
		exit 55

	fi

	clean_opt=""

	if [ $low_profile -eq 0 ]; then
		clean_opt="-q"
	fi

	"${clean_script_path}" ${clean_opt}

}


pacman_update()
{

	if [ $low_profile -eq 0 ]; then

		if ! pacman ${base_update_opt} 1>>"${log_file}" 2>&1; then

			echo "Warning: update failed, trying to clean caches first." >> "${log_file}"
			clean_caches

			if ! pacman ${base_update_opt} 1>>"${log_file}" 2>&1; then

				echo "  Error, pacman-based update failed." 1>&2
				exit 7

			fi

		fi

	else

		if ! pacman ${base_update_opt} 2>&1 | tee -a "${log_file}"; then

			echo "Warning: update failed, trying to clean caches first." >> "${log_file}"
			clean_caches

			if ! pacman ${base_update_opt} 2>&1 | tee -a "${log_file}"; then

				echo "  Error, pacman-based update failed." 1>&2
				exit 7

			fi

		fi

	fi

}



# Tired of typing it:

# Default is Debian:
distro_type="Debian"

# Not used anymore, cause often redefined:
#if cat /etc/issue | grep Arch 1>/dev/null 2>&1 ; then

distro_id_file="/etc/os-release"

if [ -f "${distro_id_file}" ]; then

	. "${distro_id_file}"

	if [ "${NAME}" = "Arch Linux" ]; then

		distro_type="Arch"

	fi

fi


#echo "Distro type: ${distro_type}"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


low_profile=1
clean_caches=1
even_ignored=1


if [ "$1" = "-l" ] || [ "$1" = "--low-profile" ]; then

	low_profile=0
	shift

fi


if [ "$1" = "-c" ] || [ "$1" = "--clean-system-caches" ]; then

	clean_caches=0
	shift

fi


if [ "$1" = "-e" ] || [ "$1" = "--even-ignored" ]; then

	even_ignored=0

	forced_packages="$(cat /etc/pacman.conf | grep '^IgnorePkg' | sed 's|^IgnorePkg[[:space:]]*=[[:space:]]*||1')"

	#echo "forced_packages = ${forced_packages}"
	shift

fi


if [ -n "$*" ]; then

	echo "  Error, unexpected arguments specified ('$*')." 1>&2

	exit 50

fi


# Only the standard output will be intercepted there, not the error one:
log_file="/root/.last-distro-update"

if [ "$(id -u)" = "0" ]; then

	# Implies Arch:
	lock_file="/var/lib/pacman/db.lck"

	if [ -e "${lock_file}" ]; then

		if [ $low_profile -eq 1 ]; then

			echo "Pacman lock file (${lock_file}) found; shall it be deleted first? [y/N]"

			read answer

			if [ "${answer}" = "y" ]; then

				/bin/rm -f "${lock_file}"
				echo "  (lock file deleted)"

			else

				echo "  (lock file NOT deleted)"

			fi

		else

			/bin/rm -f "${lock_file}"

		fi

	fi


	# Erases the previous log as well, to avoid accumulation:
	if [ -e "${log_file}" ]; then

		/bin/mv -f "${log_file}" "${log_file}.previous"

	fi

	echo "Updating the distribution now, at $(date)..." 1>"${log_file}"

	case "${distro_type}" in


		"Debian")
			if [ $low_profile -eq 1 ]; then

				(apt-get update && apt-get -y upgrade) 2>&1 | tee -a "${log_file}"

			else

				(apt-get update && apt-get -y upgrade) 1>>"${log_file}" #2>&1

			fi
			;;


		"Arch")
			# Consider as well a 'yaourt -Sy' or alike?

			if [ $clean_caches -eq 0 ]; then

				clean_caches

			fi

			keyring_opt="-S --needed --noconfirm archlinux-keyring"

			# Too many updates blocked by Haskell-related packages:
			base_update_opt="-Syu --noconfirm --ignore=ghc"

			# We start by updating the Arch keyring, as otherwise, updates made
			# after a longer duration are bound to fail due to expired keys:

			# Prevents the next 'tee' to hide errors; probably works because the
			# sh interpreter is actually a bash one:
			#
			set -o pipefail

			if [ $low_profile -eq 1 ]; then

				# To be run from the command-line:
				# (problem: tee hid the error return code)

				if ! pacman ${keyring_opt} 2>&1 | tee -a "${log_file}"; then

					echo "  Error, pacman-based Arch key update failed." 1>&2
					exit 5

				fi

				pacman_update

				if [ -n "${forced_packages}" ]; then

					pacman -Sy --noconfirm ${forced_packages} 2>&1 | tee -a "${log_file}"

				fi

			else

				# To be run from crontab for example, raising an error iff
				# appropriate:
				#
				# (avoiding: 'warning: archlinux-keyring-xxx is up to date --
				# skipping')
				#
				if ! pacman ${keyring_opt} 1>>"${log_file}" 2>&1; then

					echo "  Error, pacman-based Arch key update failed." 1>&2
					exit 25

				fi

				pacman_update

				if [ -n "${forced_packages}" ]; then

					# Could cause the output once emailed to be detected as a
					# spam:
					#
					#pacman -Sy --noconfirm ${forced_packages} 1>>"${log_file}" #2>&1
					pacman -Sy --noconfirm ${forced_packages} 1>"${log_file}" 2>&1

				fi


			fi

			# Keeps the last cache and the currently installed one; clears the
			# cache for unused packages:

			paccache="$(which paccache 2>/dev/null)"

			if [ -x "${paccache}" ]; then

				if [ $low_profile -eq 1 ]; then

					("${paccache}" -rvuk0 && "${paccache}" -rvk3) 2>&1 | tee -a "${log_file}"

				else

					("${paccache}" -rvuk0 && "${paccache}" -rvk3) 1>>"${log_file}" 2>&1

				fi

			else

				echo "Warning: no 'paccache' executable found, consider installing the 'pacman-contrib' package." 1>&2

			fi
			;;

		*)
			echo "Unsupported distribution: ${distro_type}" 1>&2
			exit 10
			;;

	esac

	res=$?

	if [ ${res} -eq 0 ]; then

		if [ $low_profile -eq 1 ]; then
			echo "... update done successfully"
		fi

		echo "... update done successfully" 1>>"${log_file}"

	else

		# pacman -Syyu might be your friend then...

		echo "... update failed (${res}). Refer to sent mail for further information." 1>>"${log_file}"

		echo "... update failed (${res}), on $(date '+%A, %B %-e, %Y at %T')."
		echo "Failure logged in '${log_file}' on $(hostname -f)."

	fi

	# To propagate errors:
	exit ${res}

else

	echo "You must be root to update your distribution!" 1>&2
	exit 5

fi
