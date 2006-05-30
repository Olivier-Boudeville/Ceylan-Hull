ARCHIVE_DIR  = @CEYLAN_ARCHIVE_DIR@/bin
ARCHIVE_FILE = "$(ARCHIVE_DIR)/`date '+%Y%m%d'`-Full-archive-bin.tar.bz2" 

SUBDIRS = tests

# These are the subdirectories which will be distributed with 'make dist' :
DIST_SUBDIRS = $(SUBDIRS)

SHELL_SCRIPTS_SET = \
	CVS-to-webserver.crontab     \
	automap.sh                   \
	beep                         \
	bong.sh                      \
	catch.sh                     \
	changeInTreeFiles.sh         \
	ci                           \
	co                           \
	computeMD5Tree.sh            \
	correctFilename.sh           \
	dci                          \
	dci-all                      \
	debian-updater.sh            \
	defaultLocations.sh          \
	dif                          \
	diffDir.sh                   \
	diffTree.sh                  \
	displayRAIDStatus.sh         \
	displayUpsStatus.sh          \
	emptyTrash.sh                \
	errorHandler.sh              \
	export-CVS-to-webserver.sh   \
	extractCVS.sh                \
	findMerges.sh                \
	ftponly.sh                   \
	generateTestRules.sh         \
	generateVersionFile.sh       \
	getDate.sh                   \
	ieeediskoff.sh               \
	ieeediskon.sh                \
	installBaseFiles.sh          \
	installGateway.sh            \
	iptables.rules-Gateway.sh    \
	iptables.rules-LANBox.sh     \
	killalways.sh                \
	killevery.sh                 \
	listProcessesBySize.sh       \
	listTreeBySize.sh            \
	makeHTMLLinks.sh             \
	makeRepositoryLinks.sh       \
	mo                           \
	n                            \
	ne                           \
	netchooser.sh                \
	noExec.sh                    \
	platformDetection.sh         \
	protectSpecialCharacters.sh  \
	putBold.sh                   \
	putBox.sh                    \
	putCenter.sh                 \
	putCode.sh                   \
	putDefinitionElement.sh      \
	putDefinitionList.sh         \
	putEmphasize.sh              \
	putFullDate.sh               \
	putImage.sh                  \
	putLink.sh                   \
	putLinkList.sh               \
	putNewsDate.sh               \
	putOrderList.sh              \
	putParagraph.sh              \
	putSnip.sh                   \
	putStrongList.sh             \
	putTOC.sh                    \
	putTable.sh                  \
	putTitle.sh                  \
	refir                        \
	remoz                        \
	replaceLineStartingBy.sh     \
	retrieve.sh                  \
	rgrep                        \
	rmCVS.sh                     \
	running.sh                   \
	searchBrokenLinks.sh         \
	setAutoRepeat.sh             \
	setDisplay.sh                \
	setGatewayBox.sh             \
	setLANBox.sh                 \
	setLocalDisplay.sh           \
	setNAT.sh                    \
	setTimeAndDateByNTP.sh       \
	showCore.sh                  \
	srm                          \
	st                           \
	stopMachine.sh               \
	styleApply.sh                \
	styleConverter.sh            \
	substitute.sh                \
	substituteInFiles.sh         \
	termUtils.sh                 \
	tidy.sh                      \
	tidyDir.sh                   \
	tidycheck                    \
	tidyupdate.sh                \
	timer.sh                     \
	toci                         \
	toci-cvs                     \
	toci-svn                     \
	toolbox.sh                   \
	unsetAll.sh                  \
	up                           \
	updateBootSequence.sh        \
	updateDirectoryFromVault.sh  \
	updateLocate.sh              \
	usbkeyoff.sh                 \
	usbkeyon.sh                  \
	valgrindTest.sh              \
	watch.sh                     \
	wh                           \
	xcdroast-launch.sh           

        
EXTRA_DIST = $(SHELL_SCRIPTS_SET)		 
                  
all: 

tar:
	@mkdir -p $(ARCHIVE_DIR)
	@tar -cvf - * 2>/dev/null | bzip2 > $(ARCHIVE_FILE)
	@echo "All bin scripts have been saved in $(ARCHIVE_FILE)"
