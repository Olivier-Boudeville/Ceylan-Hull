HULL_TOP = .


.PHONY: help help-intro help-hull


MODULES_DIRS = doc

# To override the 'all' default target with a parallel version:
BASE_MAKEFILE = true


HULL_RELEASES = $(HULL_RELEASE_ARCHIVE_BZ2) \
				$(HULL_RELEASE_ARCHIVE_ZIP) \
				$(HULL_RELEASE_ARCHIVE_XZ)



# First target for default:
help: help-intro help-hull


help-intro:
	@echo " Following main make targets are available for package $(PACKAGE_NAME):"


help-hull:
	@cd $(MYRIAD_TOP) && $(MAKE) -s help-myriad



include $(HULL_TOP)/GNUmakesettings.inc
