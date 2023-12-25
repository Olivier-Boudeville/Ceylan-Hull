# Prerequisite: HULL_TOP must be set.




# Project section.

# PROJECT_NAME should be defined on a per-project basis.
ifndef PROJECT_NAME
	PROJECT_NAME := Ceylan-Hull
endif


# PROJECT_NAME_FOR_REBAR should be defined on a per-project basis.
ifndef PROJECT_NAME_FOR_REBAR
	PROJECT_NAME_FOR_REBAR := hull
endif


# The uniquely-defined version of this layer, for all uses (including rebar and
# hex):
#
HULL_VERSION := 1.0.10


# PROJECT_VERSION should be defined on a per-project basis.
ifndef PROJECT_VERSION
	PROJECT_VERSION := $(HULL_VERSION)
endif



ifndef PACKAGE_TOP
	PACKAGE_TOP := $(HULL_TOP)
endif


HULL_RELEASE_BASE := hull-$(PROJECT_VERSION)

HULL_RELEASE_ARCHIVE_ZIP := $(HULL_RELEASE_BASE).zip
HULL_RELEASE_ARCHIVE_BZ2 := $(HULL_RELEASE_BASE).tar.bz2
HULL_RELEASE_ARCHIVE_XZ  := $(HULL_RELEASE_BASE).tar.xz



# We define the path to the Myriad layer (possibly available as a symbolic
# link).
#
# For the sake of these build-related makefiles, Ceylan dependencies will be
# searched (in that order, the one enforced in otp_utils) in a local _checkouts
# child directory (if checkout directories are used and if the top-level package
# of interest is the current one), otherwise in sibling directories (i.e. whose
# build root is at the same level as this one).
#
# This last case happens notably if not using checkout directories, or if using
# them and if all the packages mentioned here are themselves dependencies (in
# which case they are all sitting together in the _checkouts child directory).
#
# Note also we rely on the names of build roots (e.g. myriad) as opposed to
# project/repository names (e.g. Ceylan-Myriad):
#
# First priority is an existing checkout directory:
ifneq ($(wildcard $(HULL_TOP)/_checkouts/myriad/.),)
	MYRIAD_TOP = $(HULL_TOP)/_checkouts/myriad
else
	# Second, a sibling one is searched for:
	ifneq ($(wildcard $(HULL_TOP)/../myriad/.),)
		MYRIAD_TOP = $(HULL_TOP)/../myriad
   else
		# Otherwise most probably in a 'rebar3 compile' context:
		ifneq ($(wildcard $(HULL_TOP)/_build/default/lib/myriad/.),)
			MYRIAD_TOP = $(HULL_TOP)/_build/default/lib/myriad
		else
			FORCE_EVAL := $(error Unable to find the build root of Ceylan-Myriad from $(realpath .).)
		endif
	endif
endif