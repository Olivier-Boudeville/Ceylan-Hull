# There is not need for the following two lines since this script is expected
# only # to be sourced (not executed) :

#!/bin/sh
#USAGE=". $0"


# This helper script provides platform-detection facilities, so that user
# scripts are freed from UNIX particularisms, or at least can take them 
# into account more easily.
#
# Beyond testing whether the specific platform has been detected, the user
# script can test particular platform family 
# (ex : if [ "$is_bsd" -eq 0 ] ; then ...) and/or particular
# precise platform (ex : if [ "$is_netbsd" -eq 0 ] ; then ...)


# Supported architectures (ARCH variable) are :

#	- UNIX (CEYLAN_ARCH_UNIX)
#		+ System III and V (CEYLAN_ARCH_SYSTEM_5)
# 			- Linux        (CEYLAN_ARCH_LINUX)  : for all kinds of GNU/Linux
# distributions
# 			- Sun Solaris  (CEYLAN_ARCH_SOLARIS): for all various Solaris
# versions
#			- IBM AIX      (CEYLAN_ARCH_AIX) : for all various AIX versions
#			- SGI IRIX     (CEYLAN_ARCH_IRIX) : for all various IRIX versions
#			- HP UX        (CEYLAN_ARCH_HPUX) : for all various HP-UX versions
# 		+ BSD (CEYLAN_ARCH_BSD) : all BSD-based Unices, including :
#			- FreeBSD  (CEYLAN_ARCH_FREEBSD)
#			- NetBSD   (CEYLAN_ARCH_NETBSD) 
#			- OpenBSD  (CEYLAN_ARCH_OPENBSD) 
# 			- Mac OS X (CEYLAN_ARCH_MACOSX) : for all versions, including
# Panther and Tiger (10.4)
# 	- Windows (CEYLAN_ARCH_WINDOWS): for the various Windows systems, 
# including  :
#		+ Windows NT    (CEYLAN_ARCH_WINNT)
#		+ Windows 2000  (CEYLAN_ARCH_WIN2000)
#		+ Windows XP    (CEYLAN_ARCH_WINXP)
#		+ Windows Vista (CEYLAN_ARCH_WINVISTA)
#		+ Cygwin        (CEYLAN_ARCH_CYGWIN) 
# [see http://osdl.sf.net/OSDL-latest/documentation/OSDL/OSDL-generic/PortingGuide.html#cygwincase]
#		+ MinGW         (CEYLAN_ARCH_MINGW)
 

# Other available architecture variables are :
#	- CEYLAN_ARCH_UNIX_ON_WINDOWS = CEYLAN_ARCH_CYGWIN and CEYLAN_ARCH_MINGW
#	- CEYLAN_ARCH_POSIX = CEYLAN_ARCH_UNIX and CEYLAN_ARCH_UNIX_ON_WINDOWS
# Feature activation section (to integrate in configure).

# Architectures cannot be fully organized as a tree as, for example, POSIX
# compliance depends on the choice of Windows subplatforms. 

# Other platform-related variables are :
#	- CEYLAN_USES_GNU
#	- CEYLAN_ARCH_8_BIT, CEYLAN_ARCH_16_BIT, CEYLAN_ARCH_32_BIT,
# CEYLAN_ARCH_64_BIT
#	- CEYLAN_ENDIAN_LITTLE, CEYLAN_ENDIAN_BIG
#	- CEYLAN_PROC_IA32 (x86),CEYLAN_PROC_IA64 (Itanium), CEYLAN_PROC_AMD64
# (AMD), CEYLAN_PROC_POWERPC, CEYLAN_PROC_SPARC, CEYLAN_PROC_ALPHA
#	- CEYLAN_ARCH_SMP, CEYLAN_PROC_NUMBER

#echo "Trace : begin of platformDetection.sh"

if [ -z "$be_strict_on_location" ] ; then
	be_strict_on_location=1
fi


# Tells whether this script has already been sourced :
platformdetection_sourced=0

# Note : the termUtils.sh script must have sourced beforehand.

if [ "${termutils_sourced}" != 0 ] ; then

	TERMUTILS="termUtils.sh"

	#echo "Trace : will source termUtils.sh"

	if [ ! -f "${SHELLS_LOCATION}/${TERMUTILS}" ] ; then
		if [ ! -f "./${TERMUTILS}" ] ; then
			echo 1>&2
			echo "	 Error, helper script for platform detection not found (${TERMUTILS})." 1>&2
			exit 1
		else
			. ./${TERMUTILS}
		fi
	else
		. "${SHELLS_LOCATION}/${TERMUTILS}"
	fi

fi

#echo "Trace : body of platformDetection.sh"

if [ -z "$must_find_tool" ] ; then
	must_find_tool=1
fi


resetPlatformFlags()
# Allows to be sure no two different platform flags are set to true (0)
# incorrectly.
# Hence by default all of them are set to false (1).
{

	precise_platform_detected=1

	####### Roots of the platform tree :
	is_posix=1	
	is_unix=1
	is_windows=1
	
	
	
	# For UNIX :
				
	### For System III and V family :
	is_systemv=1
	
	##### GNU/Linux distributions :	
	is_linux=1

	##### Sun Solaris :
	is_solaris=1
		
	##### IBM AIX :	
	is_aix=1


	### For BSD-style OS :
	is_bsd=1
	
	##### Pure FreeBSD :
	is_freebsd=1
	
	##### Pure NetBSD :
	is_netbsd=1

	##### Pure OpenBSD :
	is_openbsd=1

	##### Mac OS X family (Jaguar, Panther, etc.) :
	is_macosx=1		



	# For Windows variations (all kinds of combinations are possible) :
	
	##### Windows 2000 :
	is_windows2000=1
	
	##### Windows XP :
	is_windowsxp=1
	
	##### Windows Vista :
	is_windowsvista=1
		
	### For UNIX on windows :
	is_unix_on_windows=1
		
	##### Cygwin runtime (beware to the licence):
	is_cygwin=1
	is_pure_cygwin=1
	
	##### MinGW runtime :
	is_mingw=1
	
	##### Build environments (not runtimes) :
	use_cygwin=1
	use_msys=1
	is_cygwin_mingw=1
	
}


displayPlatformFlags()
# Output the value of all platform flags.
{
	
	PLATFORM=
	
	if [ $is_posix -eq 0 ] ; then
		PLATFORM="${PLATFORM} POSIX"
	fi

	if [ $is_unix -eq 0 ] ; then
		PLATFORM="${PLATFORM} UNIX"
	fi

	if [ $is_windows -eq 0 ] ; then
		PLATFORM="${PLATFORM} Microsoft Windows"
	fi



	if [ $is_systemv -eq 0 ] ; then
		PLATFORM="${PLATFORM} System V"
	fi

	if [ $is_linux -eq 0 ] ; then
		PLATFORM="${PLATFORM} GNU/Linux"
	fi

	if [ $is_solaris -eq 0 ] ; then
		PLATFORM="${PLATFORM} Sun Solaris"
	fi

	if [ $is_aix -eq 0 ] ; then
		PLATFORM="${PLATFORM} IBM AIX"
	fi



	if [ $is_bsd -eq 0 ] ; then
		PLATFORM="${PLATFORM} BSD family"
	fi

	if [ $is_freebsd -eq 0 ] ; then
		PLATFORM="${PLATFORM} FreeBSD"
	fi

	if [ $is_netbsd -eq 0 ] ; then
		PLATFORM="${PLATFORM} NetBSD"
	fi

	if [ $is_openbsd -eq 0 ] ; then
		PLATFORM="${PLATFORM} OpenBSD"
	fi

	if [ $is_macosx -eq 0 ] ; then
		PLATFORM="${PLATFORM} Mac OS X"
	fi
	

	if [ $is_windows2000 -eq 0 ] ; then
		PLATFORM="${PLATFORM} 2000"
	fi

	if [ $is_windowsxp -eq 0 ] ; then
		PLATFORM="${PLATFORM} XP"
	fi

	if [ $is_windowsvista -eq 0 ] ; then
		PLATFORM="${PLATFORM} Vista"
	fi

	if [ $is_cygwin -eq 0 ] ; then
		PLATFORM="${PLATFORM} with Cywin runtime"
	fi

	if [ $is_mingw -eq 0 ] ; then
		PLATFORM="${PLATFORM} with minGW runtime"
	fi

	if [ $use_cygwin -eq 0 ] ; then
		PLATFORM="${PLATFORM} using Cywin environment"
	fi

	if [ $use_msys -eq 0 ] ; then
		PLATFORM="${PLATFORM} using MSYS environment"
	fi
	
	if [ -z "${PLATFORM}" ] ; then
		ERROR "Platform detection failed, none found."
	else
		DISPLAY "Detected platform :${PLATFORM}."
	fi
	
}




# lookUpExec and findTool are defined here so that 'uname' can be found 
# (needed for platform detection)


lookUpExec()
# Tries to find an executable for supplied command.
# Usage : if [ lookUpExec <my exec> ] ; then
# I can use here $returnedString	
# Note : the 'whereis' command should be used if available here. 
{

	OLD_PATH=$PATH
	# Two more chances of hitting the executable thanks to 'which' :
	PATH=$PATH:/bin:/usr/bin
	export PATH
	
	# The ridiculous sentence is a bad idea from Solaris :
	returnedString=`which $1 | grep -v 'Warning: ridiculously long PATH truncated' 2>/dev/null`	
	if [ $? -eq 0 ] ; then
		PATH=$OLD_PATH
		export PATH
		DEBUG "<$1> is available in $returnedString."
		return 0
	else
		PATH=$OLD_PATH
		export PATH
		DEBUG "<$1> is not available through 'which' command."
		return 1
	fi
	
}
	

findTool()
# Finds an available tool, searching the default location or trying to guess it.
# If be_strict_on_location is true (0), will raise an error as soon as 
# predicted full path for tool will not be usable. 
# Otherwise (be_strict_on_location is false, 1), it will try to
# find the tool anywhere it can. If must_find_tool is true (0), 
# on failure will raise fatal error, otherwise only a warning will be issued.
#
# Usage   : findTool <executable tool name>
# Example :  if findTool grep ; then
# GREP=$returnedString
#				...
{

	# ex : with 'grep', exec_var would be 'GREP'
	# '+' is converted on 'x' as for example g++ would result in G++ which
	# is not a valid name for a shell variable.
	exec_var=`echo "$1" | tr a-z A-Z | tr + x`
	DEBUG "Variable name for tool $1 is $exec_var."
	eval var_name=\$$exec_var
	if [ -n "${var_name}" ] ; then
	
		DEBUG "Variable name ${exec_var} had already a value, <${var_name}>."
		
		if [ -x "${var_name}" ] ; then
			DEBUG "Default value ${var_name} corresponds to a valid executable, selected."
			returnedString=${var_name}
			return 0
		else
			if [ $be_strict_on_location -eq 0 ] ; then
				ERROR "Tool look-up for <$1> : <${var_name}> is not a valid executable, and strict location checking mode is set."
				exit 2
			else
				DEBUG "Value <${var_name}> is not executable, trying to seek another."
			fi
			
		fi
	fi		
	
	# At this point, we have to search ourselves for the executable :
	# the tool is not available in its default location. 
	DEBUG "Searching for <$1>."
	if lookUpExec $1 ; then
		DEBUG "Selecting looked-up executable, $returnedString."
		return 0
	else
		if [ $must_find_tool -eq 0 ] ; then
			ERROR "Tool look-up for <$1> failed, nothing found."
			exit 3
		else
			WARNING "Tool look-up for <$1> failed, nothing found."
			return 1
		fi
	fi		
	
}



# Platform defaults.


### Windows defaults

# Default Windows prefix location :
windows_drive="c:"

# Default Windows DLL location :
windows_dll_location="${windows_drive}/WINDOWS"

# Default Cygwin location under Windows :
cygwin_location="${windows_drive}\\cygwin"

# Default MinGW location under Windows :
#mingw_location="${windows_drive}\\mingw"
mingw_location="${windows_drive}/mingw"

# MSYS location under Windows (currently not used) :
msys_location="${windows_drive}\\msys\\1.0\\"



# Platform auto-detection section :

resetPlatformFlags

findTool uname
UNAME=${returnedString}

ARCH=`${UNAME} -s`
NODE=`${UNAME} -n`


# 'platform_family_detected' is false (1) by defaut.
platform_family_detected=1

# 'precise_platform_detected' is false (1) by defaut.
precise_platform_detected=1


if [ "${ARCH}" != "Linux" ] ; then

	if [ "${ARCH}" = "NetBSD" ] ; then
		GREP="/usr/bin/grep"
	else	
		GREP="/bin/grep"
	fi
		
	findTool grep
	GREP=$returnedString

	if ${UNAME} -s | ${GREP} -i cygwin 1>/dev/null 2>&1 ; then
	
		DEBUG "Windows OS detected."                
		is_windows=0
		platform_family_detected=0

		use_cygwin=0
		             
		if [ -d "$mingw_location" ] ; then

			is_mingw=0
			is_cygwin_mingw=0
			precise_platform_detected=0
			
			MINGW_ROOT="$mingw_location"
			export MINGW_ROOT
			
			DEBUG "Cygwin/minGW detected."			
                         
		else
		
			DEBUG "Pure Cygwin (upon Windows, no minGW found in $mingw_location) platform detected."
			is_pure_cygwin=0
			precise_platform_detected=0
			
		fi
		
		# TO-DO : add MSYS detection (use_msys)
		
	elif ${UNAME} -s | ${GREP} -i mingw 1>/dev/null 2>&1 ; then
		DEBUG "Windows MSYS/mingw detected."
		is_windows=0
		platform_family_detected=0

		use_msys=0
		precise_platform_detected=0
	
	elif ${UNAME} -s | ${GREP} -i darwin 1>/dev/null 2>&1 ; then
	
		DEBUG "MacOS X OS detected."
		is_bsd=0		
		platform_family_detected=0

		is_macosx=0		
		precise_platform_detected=0
		
	elif ${UNAME} -s | ${GREP} -i BSD 1>/dev/null 2>&1 ; then

		DEBUG "BSD-style OS detected."
		is_bsd=0		
		platform_family_detected=0
		
		if ${UNAME} -s | ${GREP} -i NetBSD 1>/dev/null 2>&1 ; then
			is_netbsd=0
			precise_platform_detected=0
			
		elif ${UNAME} -s | ${GREP} -i FreeBSD 1>/dev/null 2>&1 ; then
		
			is_freebsd=0
			precise_platform_detected=0
			
		else
		
			WARNING "Unidentified BSD-style OS."
			# precise_platform_detected still false (1)

		fi
		
	else

		# precise_platform_detected still false (1)
		WARNING "Platform detection failed, unknown platform."
		
	fi	
      
else

	DEBUG "Linux OS detected."
	is_posix=0
	is_unix=0
	is_systemv=0
	platform_family_detected=0
	
	is_linux=0        
	precise_platform_detected=0
	
fi


#TRACE "Per-platform adaptation performed."


#displayPlatformFlags




# Cubbyhole section (mostly deprecated).

# Compilers section.


# Basic compiler type is defined by COMPILER_FAMILY (ex : gcc or icpc, i.e.
# Intel compiler)
# COMPILER_FAMILY variable is useful to select options available for an 
# entire compiler family
# Precise compiler version will be defined in CPP_COMPILER for effective
# compiler use.

# COMPILER_FAMILY known values are :
# - gcc : for the GNU compiler collection, including minGW
# - icpc : Intel's C++ compiler
# - visualcpp : Microsoft's Visual C++ compiler

# Selected compiler family :
COMPILER_FAMILY=gcc

# gcc family.

# One may update its GCC root accordingly to his installation, to select 
# the compiler to be used :
GCC_ROOT=FIXME/gcc-${gcc_VERSION}
GPP=`PATH=${GCC_ROOT}/bin:$PATH which g++ 2>/dev/null`
GPP_LIB="-L${GCC_ROOT}/lib -lgcc_s -lstdc++"

GDB_ROOT=FIXME/gdb-${gdb_VERSION}
GDB=`PATH=${GDB_ROOT}/bin:$PATH which gdb 2>/dev/null`


# Intel's icpc family.

INTEL_ROOT=/opt/intel
ICPC_7_1=${INTEL_ROOT}/compiler70/ia32/bin/icpc
ICPC=${ICPC_7_1}


# Stripping utility.
STRIP=`which strip 2>/dev/null`
STRIP_OPT="--strip-all"


# Build flags and dependencies.

CCMAKE=${CPP_COMPILER}



# libtool handles it for gcc only :
PICFLAGS=-fPIC
DSOFLAGS=-shared
LD_DSO=${CCC}
AR="ar cr"

DEPFLAGS=-MM
DEPFILTER=cat