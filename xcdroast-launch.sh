#!/bin/bash

if [ `id -u` -eq 0 ] ; then
	echo "Warning : should not be run as root (there may be remote display problem if not directly connected as root, but if SCSI support is compiled in the kernel, might only work as root)" 1>&2
	# Only a warning : exit 1
fi
	
echo "Launching xcdroast for private/research/educational non-commercial use"

# ftp://ftp.berlios.de/pub/cdrecord/ProDVD/README : 
# this key has been renewed on February 16th 2005
export CDR_SECURITY=8:dvd,clone:sparc-sun-solaris2,i386-pc-solaris2,i586-pc-linux,x86_64-unknown-linux,x86_64-pc-linux,powerpc-apple,hppa,powerpc-ibm-aix,i386-unknown-freebsd,i386-unknown-openbsd,i386-unknown-netbsd,powerpc-apple-netbsd,i386-pc-bsdi,mips-sgi-irix,i386-pc-sco,i586-pc-cygwin:1.11::1130000000:::private/research/educational_non-commercial_use:amz80r0cFc22rStnPatPW6OJPHS44.xCl2LPIpyKt.SuICSsGTMY7YzsmFT


# Ensure that generic SCSI support compiled as module is used if necessary :
insmod ide-scsi 1>/dev/null 2>&1

# Be sure in case this program is used remotely as root that it is run from a real root
# session (as obtained with 'ssh roo@burner', not as 'ssh user@burner; su' since 
# X-forwarding would not be effective.
xcdroast 2>/dev/null &
