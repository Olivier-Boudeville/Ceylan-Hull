#!/bin/sh

usage="Usage: $(basename $0) [-q]: updates the current distribution, and traces it.
  Option -q: quiet mode, no output if no error (suitable for crontab)
  Supported distributions: Arch, Debian."


# Many problems with Haskell:

#pacman -Rsc pandoc
#pacman -Syu pandoc
#pacman -Su --ignore=ghc
#pacman -Rsdd haskell-fail


# Tired of typing it:

# Default is Debian:
distro_type="Debian"

# Not used anymore, cause often redefined:
#if cat /etc/issue | grep Arch 1>/dev/null 2>&1 ; then

distro_id_file="/etc/os-release"

if [ -f "${distro_id_file}" ]; then

	. "${distro_id_file}"

	if [ "$NAME" = "Arch Linux" ]; then

		distro_type="Arch"

	fi

fi


#echo "Distro type: ${distro_type}"


quiet=1

if [ "$1" = "-q" ]; then

	quiet=0

fi


# Only standard output will be intercepted there, not the error one:
log_file="/root/.last-distro-update"

if [ "$(id -u)" -eq 0 ]; then

	lock_file="/var/lib/pacman/db.lck"

	if [ -e "${lock_file}" ]; then


		if [ $quiet -eq 1 ]; then

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
	echo "Updating the distribution now, at $(date)..." 1>${log_file}

	case "${distro_type}" in

		"Debian")
			if [ $quiet -eq 1 ]; then

				( apt-get update && apt-get -y upgrade ) 2>&1 | tee -a  ${log_file}

			else

				( apt-get update && apt-get -y upgrade ) 1>>${log_file} #2>&1

			fi
			;;

		"Arch")
			# Consider as well a 'yaourt -Sy' or alike?

			# Too many updates blocked by Haskell-related packages:
			pacman_opt="-Syu --noconfirm --ignore=ghc"

			if [ $quiet -eq 1 ]; then

				# To be run from the command-line:
				pacman ${pacman_opt} 2>&1 | tee -a ${log_file}

			else

				# To be run from crontab for example, raising an error iff
				# appropriate:
				#
				pacman ${pacman_opt} 1>>${log_file} #2>&1

			fi

			;;

		*)
			echo "Unsupported distribution: ${distro_type}" 1>&2
			exit 10
			;;

	esac

	res=$?

	if [ ${res} -eq 0 ]; then

		echo "... update done successfully"
		echo "... update done successfully" 1>>${log_file}

	else

		# pacman -Syyu might be your friend then...

		echo "... update failed ($res). Refer to sent mail for further information." 1>>${log_file}

		echo "... update failed ($res), on " $(date '+%A, %B %-e, %Y at %T')"."
		echo "Failure logged in '${log_file}' on $(hostname -f)."

	fi

	# To propagate errors:
	exit ${res}

else

	echo "You must be root to update your distribution!" 1>&2
	exit 5

fi
