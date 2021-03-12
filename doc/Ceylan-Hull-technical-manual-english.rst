
.. _Top:


.. title:: Welcome to the Ceylan-Hull 1.0 documentation

.. comment stylesheet specified through GNUmakefile


.. role:: raw-html(raw)
   :format: html

.. role:: raw-latex(raw)
   :format: latex


:raw-html:`<a name="hull_top"></a>`

:raw-html:`<div class="banner"><p><em>Hull 1.0 documentation</em> <a href="http://hull.esperide.org/">browse latest</a> <a href="https://olivier-boudeville.github.io/Ceylan-Hull/">browse mirror</a> <a href="Ceylan-Hull-technical-manual-english.pdf">get PDF</a> <a href="#hull_top">go to top</a> <a href="#hull_bottom">go to bottom</a> <a href="https://github.com/Olivier-Boudeville/Ceylan-Hull">go to project</a> <a href="mailto:about(dash)hull(at)esperide(dot)com?subject=[Ceylan-Hull%201.0]%20Remark">email us</a></p></div>`



:raw-html:`<center><img src="hull-title.png" width="20%"></img></center>`
:raw-latex:`\centering \includegraphics[scale=0.3]{hull-title.png}`

.. comment Note: this is the latest, current version of the Hull 2.x documentation, directly obtained from the one of Hull 1.x.



============================================
*A collection of all kinds of shell scripts*
============================================


:Organisation: Copyright (C) 2008-2021 Olivier Boudeville
:Contact: about (dash) hull (at) esperide (dot) com
:Creation date: Sunday, August 17, 2008
:Lastly updated: Friday, March 12, 2021
:Version: 1.0.4
:Dedication: Users and maintainers of ``Ceylan-Hull``, version 1.0.
:Abstract:

	The role of ``Hull`` is to concentrate various, generic-purpose convenience shell scripts, on behalf of the `Ceylan <https://github.com/Olivier-Boudeville/Ceylan>`_ project.


.. meta::
   :keywords: Hull, shell, scripts, sh, bash




The latest version of this documentation is to be found at the `official Ceylan-Hull website <http://hull.esperide.org>`_ (``http://hull.esperide.org``).

:raw-html:`This Hull documentation is also available in the PDF format (see <a href="Ceylan-Hull-technical-manual-english.pdf">Ceylan-Hull-technical-manual-english.pdf</a>), and mirrored <a href="http://olivier-boudeville.github.io/Ceylan-Hull/">here</a>.`

:raw-latex:`The documentation is also mirrored \href{https://olivier-boudeville.github.io/Ceylan-Hull/}{here}.`


--------
Overview
--------

Here are **a few scripts, sorted by themes, that may be convenient for at least some users**.

Many of them can display their intended usage on the console by specifying them the ``-h`` / ``--help`` command-line option.

In each category, scripts are roughly sorted by decreasing interest/update status. The scripts that we deem the most useful are described more precisely at the end of this document.

As much as possible, we try to name these scripts functionally rather than in terms of tools, so that the implementation they rely upon can be updated as transparently as possible (i.e. with as little change as possible in the user's habits).

Each script entry is a link pointing directly to the script itself.

Most of them are certainly not rocket science.


.. Note:: Many of these scripts may be a bit outdated, as only a small subset of them are routinely used; rely on them with caution!

		  And tell us if you would like some of them to be updated.




:raw-latex:`\pagebreak`



.. _`table of contents`:


.. contents:: Table of Contents
  :depth: 5




:raw-latex:`\pagebreak`


--------------------------------------------------
Listing of the recommended shell scripts per usage
--------------------------------------------------


Related to Filesystems
======================


To search for files and content
-------------------------------

- `wh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/wh>`_ ("where") : a more convenient "find"; see the `wh full usage`_

- `regrep <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/regrep>`_: recursive grep for the ones that lack it; see the `regrep full usage`_



To list filesystem elements
---------------------------

- `list-filesystem-entries-by-size.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-filesystem-entries-by-size.sh>`_: lists, from any specified directory otherwise from the current one, the direct filesystem entries (local files and directories), sorted by decreasing size of their content

- `list-files-in-tree-by-size.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-files-in-tree-by-size.sh>`_: lists, from any specified directory otherwise from the current one, all files in tree, sorted by decreasing size of their content

- `list-files-in-tree-by-most-recent-modification-time.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-files-in-tree-by-most-recent-modification-time.sh>`_: lists, from any specified directory otherwise from the current one, all files in tree, sorted from the most recently modified to the least




To fix names, paths, permissions, content
-----------------------------------------

- `fix-filename.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-filename.sh>`_: "corrects" the name of the specified file (or directory), to remove spaces and quotes (replaced by '-'), accentuated characters in it, etc.

- `fix-paths-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-paths-in-tree.sh>`_: does the same as ``fix-filename.sh``, yet in a tree

- `fix-file-permissions.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-file-permissions.sh>`_: corrects, for all files in the current directory, the UNIX permissions for the most common file extensions

- `set-files-unexecutable-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-files-unexecutable-in-tree.sh>`_: ensures that all files found recursively from the current directory are not executable

- `fix-unbreakable-spaces.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-unbreakable-spaces.sh>`_: removes any unbreakable space in specified file

- `fix-unbreakable-spaces-in-source-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-unbreakable-spaces-in-source-tree.sh>`_: removes any unbreakable space in specified tree

- `fix-whitespaces.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-whitespaces.sh>`_: fixes whitespace problems into specified file; useful to properly format files that shall committed when not using Emacs as text editor

- `rename-files-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/rename-files-in-tree.sh>`_ (just an example of pattern substitution in filenames)



To inspect file and directory content
-------------------------------------

- `compute-checksum-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/compute-checksum-in-tree.sh>`_: computes the checksum of all files in specified tree and stores them in the specified text output file

- `display-tree-stats.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/display-tree-stats.sh>`_: displays simple, key stats about the specified tree (typically in order to compare merged trees)



To compare files and trees
--------------------------

- `diff-dir.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/diff-dir.sh>`_: performs a (single-level, non-recursive) comparison of the content of the two specified directories

- `diff-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/diff-tree.sh>`_: compares all files that are present both in first and second trees, and warns if they are not identical; warns too if some files are in one directory but not in the other

See also: Myriad's `merge.sh <https://github.com/Olivier-Boudeville/Ceylan-Myriad/blob/master/src/apps/merge-tool/merge.sh>`_ script, a considerably more powerful tool for merging trees.



To copy/transfer
----------------

- `transfer-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/transfer-tree.sh>`_: copies (possibly through the network) a tree existing in one location to another one, in a merge-friendly manner



To remove filesystem elements
-----------------------------

- `srm <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/srm>`_ (for "secure rm"): stores deleted files in a trash directory, instead of deleting them directly; see the `srm full usage`_

- `empty-trash.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/empty-trash.sh>`_: empties the trash directory that can be filled thanks to our ``srm`` script




Related to (UNIX) Processes
===========================

- `top.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/top.sh>`_: triggers the best "top" available, to monitor processes and system resources

- `watch.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/watch.sh>`_: tracks (over time) processes that may be transient

- `benchmark-command.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/benchmark-command.sh>`_: returns a mean resource consumption for the specified shell command

- `list-processes-by-size.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-processes-by-size.sh>`_: lists processes by decreasing size in RAM

- `list-processes-by-cpu-use.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-processes-by-cpu-use.sh>`_: lists processes by decreasing use of CPU

- `kill-every.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/kill-every.sh>`_: kills all processes that match specified name pattern

- `kill-always.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/kill-always.sh>`_: as long as this script is kept running, kills any process matching the specified name




Related to Network Management
=============================

- `test-network.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/test-network.sh>`_: diagnoses whether the various network basic facilities are functional (IP connectivity, DNS, on the LAN or on the WAN)

- `manage-wifi.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/manage-wifi.sh>`_: starts/gets status/scans/stops the wifi support

- `ip-scan.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/ip-scan.sh>`_: scans all IPs with any specified prefix, searching for ICMP ping answers (useful to locate some devices in a local network)




For Development
===============

- `update-copyright-notices.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-copyright-notices.sh>`_: updates the copyright notices of code of specified type found from specified root directory (to run at each new year)

- `update-all-copyright-notices.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-all-copyright-notices.sh>`_: updates the copyright notices of code of specified type found from specified root directory, based on the specified year range

- `add-header-to-files.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/add-header-to-files.sh>`_: adds specified header to specified files

- `remake.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/remake.sh>`_: forces a remake of specified generated file (ex: ``.o`` or ``.beam``)

- `list-core-dumps-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-core-dumps-in-tree.sh>`_: locates all core dump files in current tree

- `test-with-valgrind.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/test-with-valgrind.sh>`_: uses Valgrind to perform quality test on the specified executable

- `reformat-source-style.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/reformat-source-style.sh>`_: applies some style change to specified file

- `reformat-source-style-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/reformat-source-style-in-tree.sh>`_: applies some style change to C/C++ files in specified tree


See also the Erlang-related `Myriad scripts <http://myriad.esperide.org/#erlang-dedicated-scripts>`_.



Replacement-related
===================

- `replace-in-file.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/replace-in-file.sh>`_: replaces in specified file the specified target pattern with the replacement one

- `replace-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/replace-in-tree.sh>`_: replaces, in files matching the specified pattern found from the current directory, the specified target pattern with the replacement one

- `substitute-pattern-in-file.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/substitute-pattern-in-file.sh>`_ (possible duplicate): replaces in specified file every source pattern by specified target one

- `substitute-pattern-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/substitute-pattern-in-tree.sh>`_ (possible duplicate): substitutes every source pattern by specified target one in all files, starting recursively from current directory

- `replace-lines-starting-by.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/replace-lines-starting-by.sh>`_: replaces in specified file every line starting with the specified pattern by the specified full line



Multimedia-related
==================


For Audio
---------

- `play-audio.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/play-audio.sh>`_: performs an audio-only playback of specified content files (including video ones) and directories

- `extract-audio-from-video.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/extract-audio-from-video.sh>`_: strips the video information from specified MP4 file to generate a pure audio file (.ogg) out of it (original MP4 file not modified); useful, as the resulting file is smaller and less resource-demanding to playback

- `resample.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/resample.sh>`_: resamples the target audio file to the specified frequency, keeping the same bitdepth

- `ogg-encode.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/ogg-encode.sh>`_: encodes specified sound file in OggVorbis after having removed any leading and ending silences, adjusting volume

- `convert-vorbis-to-mp3.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/convert-vorbis-to-mp3.sh>`_: converts a Vorbis-encoded Ogg file to MP3 (sometimes it is useful to use older players)

- `convert-vorbis-tree-to-mp3.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/convert-vorbis-tree-to-mp3.sh>`_: converts all Vorbis-encoded Ogg files to MP3 in specified tree

- `trim-silence-in.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/trim-silence-in.sh>`_: removes any silence at begin and end of specified file, which is updated (initial content is thus not kept)



For Voice Synthesis / Text-To-Speech
------------------------------------

- `say.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/say.sh>`_: says specified text, based on text to speech

- `record-speech.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/record-speech.sh>`_: records the specified speech with specified voice in the specified prefixed filename

- `install-speech-syntheses.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/install-speech-syntheses.sh>`_: installs all listed voices for speech synthesis

- `get-and-install-MBROLA-and-voices.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/get-and-install-MBROLA-and-voices.sh>`_: installs MBROLA and corresponding voices

- `test-espeak-voices.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/test-espeak-voices.sh>`_: tests the voices supported by espeak

- `test-voices.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/test-voices.sh>`_: tests all supported voices



For Video
---------

- `convert-mov-to-x264-mp4.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/convert-mov-to-x264-mp4.sh>`_: converts specified MOV file to MP4

- `fix-video-mode.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-video-mode.sh>`_: forces a specified video resolution



For Snapshots (Camera Pictures)
-------------------------------

- `rename-snapshot.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/rename-snapshot.sh>`_: renames the specified picture file, based on its embedded date (used as a prefix, if appropriate), and with a proper extension

- `rename-snapshots.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/rename-snapshots.sh>`_: renames snapshots found from current directory, so that they respect better naming conventions

- `generate-lighter-image.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/generate-lighter-image.sh>`_: generates a lighter (smaller and of decreased quality) version of the specified image

- `generate-lighter-images.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/generate-lighter-images.sh>`_: reduces the size of image files found in current directory




CCTV-related
============

- `monitor-cctv.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/monitor-cctv.sh>`_: performs online, direct monitoring from a networked security camera (CCTV), with an average quality and no audio

- `fetch-cctv-monitorings.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fetch-cctv-monitorings.sh>`_: fetches locally (and leaves on remote host) the set of CCTV recordings dating back from yesterday and the three days before; designed to be called typically from the crontab of your usual reviewing user

- `review-cctv-monitorings.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/review-cctv-monitorings.sh>`_: allows to (possibly) fetch from server, and review conveniently / efficiently any set of CCTV recordings dating back from yesterday and the three days before



Document-related
================

- `check-rst-includes.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/check-rst-includes.sh>`_: checks that all RST files found from current directory are included once and only once in the sources found

- `convert-rst-to-mediawiki.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/convert-rst-to-mediawiki.sh>`_: converts specified RST source file in a mediawiki counterpart file

- `generate-mermaid-diagram.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/generate-mermaid-diagram.sh>`_: generates a PNG file corresponding to the specified file describing a Mermaid diagram

- `generate-pdf-from-latex.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/generate-pdf-from-latex.sh>`_: generates a PDF file from a LaTeX one, and displays it

- `regenerate-rst-files.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/regenerate-rst-files.sh>`_: updates generated files from more recent docutils files

- `track-rst-updates.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/track-rst-updates.sh>`_: tracks changes in the specified RST source file in order to regenerate the target file accordingly

- `spell-check-rst-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/spell-check-rst-tree.sh>`_: spellchecks all RST files found from current directory


One may also rely on the `Ceylan-Myriad's scripts for documentation <http://myriad.esperide.org/#to-generate-documentation>`_, notably `generate-docutils.sh <https://github.com/Olivier-Boudeville/Ceylan-Myriad/blob/master/src/scripts/generate-docutils.sh>`_ and `generate-pdf-from-rst.sh <https://github.com/Olivier-Boudeville/Ceylan-Myriad/blob/master/src/scripts/generate-pdf-from-rst.sh>`_.


For Version Control System (VCS)
================================

- `dci <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/dci>`_: assists efficiently and conveniently the commit of specified file(s)

- `dci-all <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/dci-all>`_: selects recursively from current directory the files that should be committed (either added or modified), and commits them; for each of the modified files, shows the diff with previous version before requesting a commit message

- `dif <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/dif>`_: shows on the console the differences between the current versions of the (possibly specified) files on the filesystem and the staged ones (i.e. the changes that might be added)

- `difg <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/difg>`_: graphical version of ``dif``

- `dif-prev.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/dif-prev.sh>`_: compares the current (committed) version of specified file(s) with their previous one

- `difs <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/difs>`_: shows the differences between the staged files and their committed version

- `st <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/st>`_: shows the current VCS status of the specified files

- `up <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/up>`_: updates the current local version of the VCS repository

- `show-branch-hierarchy.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/show-branch-hierarchy.sh>`_: shows the hierarchy of the branches in the current VCS repository




System-related
==============


Admin-related
-------------

- `check-filesystem.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/check-filesystem.sh>`_: checks for errors, and repairs if needed, the specified  filesystem

- `check-ntp.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/check-ntp.sh>`_: reports the current, local NTP status

- `set-time-and-date-by-ntp.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-time-and-date-by-ntp.sh>`_: sets time and date by NTP thanks to specified or default server

- `display-ups-status.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/display-ups-status.sh>`_: displays the status of specified UPS

- `report-raid-disk-status.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/report-raid-disk-status.sh>`_: reports the status of the specified RAID array (script for automation)

- `report-disk-smart-monitoring.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/report-disk-smart-monitoring.sh>`_: reports a state change of the specified SMART-compliant disk (script for automation)

- `report-ups-status.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/report-ups-status.sh>`_: reports a state change of the specified UPS (script for automation)

- `record-system-settings.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/record-system-settings.sh>`_: records in-file the main system settings of the local host

- `get-host-information.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/get-host-information.sh>`_ (possible duplicate): returns the main system settings of the local host, and stores them in-file

- `shutdown-local-host.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/shutdown-local-host.sh>`_: shutdowns current, local host after having performed any relevant system update

- `update-locate-database.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-locate-database.sh>`_: updates the 'locate' database, for faster look-ups in filesystems

- `mount-encrypted-usb-device.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/mount-encrypted-usb-device.sh>`_: mounts specified LUKS-encrypted device (ex: a USB key, or a disk), as root or (preferably) as a normal user



To install software
-------------------

.. install-stardict.sh

- `install-rebar3.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/install-rebar3.sh>`_: installs the rebar3 Erlang build tool

- `install-godot.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/install-godot.sh>`_: installs the Godot 3D engine

- `install-unity3d.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/install-unity3d.sh>`_: install the Unity3D engine



System information-related
--------------------------

- `display-opengl-information.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/display-opengl-information.sh>`_: displays information regarding the local OpenGL support

- `display-raid-status.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/display-raid-status.sh>`_: displays information regarding a local RAID array.


Convenience-related
-------------------

- `activate-keyboard-backlighting.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/activate-keyboard-backlighting.sh>`_: (des)activates (per-level) the keyboard backlighting

- `disable-touchpad-if-mouse-available.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/disable-touchpad-if-mouse-available.sh>`_: ensures that the touchpad (if any) is enabled iff there is no mouse connected

- `toggle-touchpad-enabling.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/toggle-touchpad-enabling.sh>`_: toggles the touchpad activation state

- `display-to-video-projector.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/display-to-video-projector.sh>`_: displays a screen to a video projector (various examples thereof)

.. - `fix-acpi.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fix-acpi.sh>`_



Distribution-related
--------------------

- `update-distro.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-distro.sh>`_: updates the current distribution, and traces it

- `update-aur-installer.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-aur-installer.sh>`_: updates the local AUR (Arch User Repository) installer

.. - `debian-updater.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/debian-updater.sh>`_



For encryption
==============


- `crypt.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/crypt.sh>`_: encrypts as strongly as reasonably possible the specified file(s), and removes their unencrypted sources

- `decrypt.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/decrypt.sh>`_: decrypts specified file(s) (does not remove their encrypted version)



For security
============


- for the management of credentials (i.e. sets of login/password):

  - `open-credentials.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/open-credentials.sh>`_: unlocks (decrypts) the credential file whose path is read from the user environment, and opens it; once closed, re-locks it (with the same passphrase)

  - `lock-credentials.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/lock-credentials.sh>`_: locks (encrypts) the credential file whose path is read from the user environment

  - `unlock-credentials.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/unlock-credentials.sh>`_: unlocks (decrypts) the credential file whose path is read from the user environment

- `lock-screen.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/lock-screen.sh>`_: locks immediately the screen

- `inspect-opened-ports.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/inspect-opened-ports.sh>`_: lists the local TCP/UDP ports that are currently opened

.. - `ftp-only-shell.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/ftp-only-shell.sh>`_



Firewall configuration
======================

- `iptables.rules-Gateway.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/iptables.rules-Gateway.sh>`_: manages a well-configured firewall suitable for a gateway host with masquerading and various services

- `iptables.rules-Minimal-gateway.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/iptables.rules-Minimal-gateway.sh>`_: sets up a minimal yet functional firewall suitable for a gateway host

- `iptables.rules-LANBox.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/iptables.rules-LANBox.sh>`_: manages a well-configured firewall suitable for a LAN host

- `iptables.rules-inspect.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/iptables.rules-inspect.sh>`_: lists the currently-used firewall rules

- `iptables.rules-FullDisabling.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/iptables.rules-FullDisabling.sh>`_: disables all firewall rules

- `iptables.rules-TemporaryDisabling.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/iptables.rules-TemporaryDisabling.sh>`_: disables temporarily all firewall rules



.. iptables.rules-OrgeServer.sh



For smartphones
===============

- `adb-pull.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/adb-pull.sh>`_: uploads specified local files, possibly based on expressions to the already connected and authorizing Android device

- `adb-push.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/adb-push.sh>`_: downloads in the current directory, from the already connected and authorizing Android device, files and directories (recursively)

.. - `transfer-to-mobile.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/transfer-to-mobile.sh>`_

- `set-usb-tethering.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-usb-tethering.sh>`_: sets (or stops) USB tethering on local host, typically so that a smartphone connected through USB and with such tethering enabled shares its Internet connectivity with this host



For archive management
======================

- `archive-emails.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/archive-emails.sh>`_: archives properly and reliably (compressed, cyphered, possibly transferred) the user emails

- Manages reference version of files, by storing them in a "vault":

  - `catch.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/catch.sh>`_: stores a file in a vault directory and makes a symbolic link to it, so that even if current tree is removed, this file will not be lost

  - `retrieve.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/retrieve.sh>`_: retrieves at least one file already stored in vault by creating link towards it, from current directory

  - `update-directory-from-vault.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-directory-from-vault.sh>`_: updates all files in specified directory from their vault counterparts

- `make-git-archive.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/make-git-archive.sh>`_: makes a backup (as an archived GIT bundle) of specified project directory, stored in specified archive directory

- `snapshot.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/snapshot.sh>`_: performs a snapshot (tar.xz.gpg archive) of specified directory

- `list-for-backup.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/list-for-backup.sh>`_: enumerates in current directory all files, specifies their name, size and MD5 sum, and stores the result in a relevant file



Web-related facilities
======================

- `generate-html-map.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/generate-html-map.sh>`_: generates a simple HTML map with links from the available pages in specified web root

- `backup-directory.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/backup-directory.sh>`_: backups specified directory to specified backup directory on the specified server, using specified SSH port

- `fetch-website.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/fetch-website.sh>`_: downloads correctly, recursively (fully but slowly) web content accessible from the specified URL

.. - `detect-broken-links.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/detect-broken-links.sh>`_

.. - `check-html-file.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/check-html-file.sh>`_

.. - `tidy-html-file.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/tidy-html-file.sh>`_

.. - `tidy-html-in-tree.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/tidy-html-in-tree.sh>`_

- `generate-awstats-report.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/generate-awstats-report.sh>`_: to trigger the generation of an Awstats report (prefer using `US-Web <http://us-web.esperide.org>`_ instead)

- `make-markup-shortcut-links.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/make-markup-shortcut-links.sh>`_: creates shortcuts (symlinks) for the ``put-*-markup.sh`` micro-scripts, in order to assist a bit the user of following languages:

  - for HTML: ``bold``, ``box``, ``cent``, ``code``, ``def``, ``defel``, ``em``, ``img``, ``linked``, ``lnk``, ``ordered``, ``para``, ``sni``, ``strong``, ``table``, ``tit``, ``toc``
  - for RST: ``imgr``, ``linkr``
  - in general: ``fuda``, ``newda``



For user notifications
======================

- `notify.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/notify.sh>`_: notifies the user about specified message, possibly with a title and a category

- `timer-at.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/timer-at.sh>`_: requests to trigger a timer notification at specified (absolute) timestamp

- `timer-in.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/timer-in.sh>`_: requests to trigger a timer notification in specified duration

- `timer-every.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/timer-every.sh>`_: requests to trigger (indefinitely, just use CTRL-C to stop) a timer notification every specified duration

- `start-jam-session.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/start-jam-session.sh>`_: starts a jam session interrupted by a notification every period, to avoid remaining still for too long

- `bong.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/bong.sh>`_: plays the specified number of bong sound(s)

- `beep.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/beep.sh>`_: plays a beep to notify the user of an event



Shell Helpers
=============

To facilitate shell sessions:

- `mo <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/mo>`_: shorthand for a relevant version of ``more``

- `hide.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/hide.sh>`_: hides specified file or directory (simply by adding a ``-hidden`` suffix to its filename), while `unhide.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/unhide.sh>`_ does the reverse operation

- `set-display.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-display.sh>`_: sets the X display to specified host; if none is specified, sets it to the local one

- `get-date.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/get-date.sh>`_: returns the current date in our standard short format (ex: ``20210219``)



About Configuration
===================


For keyboards
-------------

- `reset-keyboard-mode.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/reset-keyboard-mode.sh>`_: resets the keyboard mode, typically should it have been modified by a misbehaving program

- `set-keyboard-layout.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-keyboard-layout.sh>`_: sets the X keyboard layout

- `set-french-keyboard.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-french-keyboard.sh>`_: sets the keyboard layout to the French (for all X)

- `set-auto-repeat.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-auto-repeat.sh>`_: enables the keyboard auto-repeat mode (to issue multiple characters in case of longer keypresses)



Of Environment and related
--------------------------

- `unset-all-environment-variables.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/unset-all-environment-variables.sh>`_: unsets all environment variables, typically to rule out stranger account-related side-effects

- `update-emacs-modules.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/update-emacs-modules.sh>`_: updates the basic Emacs modules that we use

- `set-local-environment.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/set-local-environment.sh>`_: sets up a few installation conventions



Script-related
==============

- `protect-special-characters.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/protect-special-characters.sh>`_: prevents special characters in specified expression from being interpreted by tools like sed

- `encode-to-rot13.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/encode-to-rot13.sh>`_: returns a ROT13-encoded version of specified parameters

- `default-locations.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/default-locations.sh>`_: detects the path of the most common UNIX-related tools (this script shall be sourced, not executed)

.. - `shell-toolbox.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/shell-toolbox.sh>`_

- `term-utils.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/term-utils.sh>`_: defines facilities to make a better use of terminals, as a very basic, limited text user interface (this script shall be sourced, not executed)




Launch-related
==============

.. - `brave.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/brave.sh>`_

- `e <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/e>`_: to edit (i.e. open potentially for updating) all kinds of files
- `v <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/v>`_: to view (i.e. open for reading only) all kinds of files
- `email.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/email.sh/>`_ / `courriels.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/courriels.sh>`_: to launch a suitable e-mail client
- `launch-irc.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/launch-irc.sh>`_: to launch a suitable IRC client



Miscellaneous
=============

- `eat-CPU-cycles.sh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/eat-CPU-cycles.sh>`_: generates some CPU load




:raw-latex:`\pagebreak`


.. _`wh full usage`:
.. _`regrep full usage`:
.. _`srm full usage`:

----------------------------------------------------
Detailed description of some frequently-used scripts
----------------------------------------------------


`wh <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/wh>`_
  wh (for "where"): searches (as a more user-friendly 'find') all files and directories matching <filePattern>, from <starting_directory> if specified, otherwise from current directory.

  Usage: wh [-h|--help] [--verbose] [-q|--quiet] [--no-path] [--exclude-path <a directory>] <filePattern> [<startingDirectory>]

  Options:

	| [-q|--quiet]: only returns file entries (no extra display); suitable for scripts (ex: for f in $(wh -q 'foo*'); do...)
	| --no-path: returns the filenames without any leading path
	| --exclude-path DIR: excludes specified directory DIR from search



`regrep <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/regrep>`_
  regrep: recursive grep for the ones that lack it.

  Usage: regrep [-v|--verbose] [-q|--quiet] [-i|--insensitive] [-r|--restructured] <Expression to be found in files> [<Filter on files>]

  Options:

	| -v or --verbose: be specifically verbose
	| -q or --quiet: be specifically quiet, just listing matches
	| -f or --filenames-only: display only filenames, not also the matched patterns, and if there are multiple matches in the same file, its filename will be output only once (implies quiet)
	| -i or --insensitive: perform case-insensitive searches in the content of files, and also when filtering any filenames
	| -r or --restructured: use ReStructured text mode (skip tmp-rst directories, search only *.rst files)

  Example: regrep -i 'little red rooster' '*.txt'



`srm <https://github.com/Olivier-Boudeville/Ceylan-Hull/blob/master/srm>`_
  srm (for "secure rm"): stores deleted files in a trash instead of deleting them directly, in order to give one more chance of retrieving them if necessary. Ensures that no two filenames can collide in trash so that all contents are preserved.

  Usage: srm <files to delete securely>

  See also: emptyTrash.sh



--------
See also
--------

- the ``tests`` subdirectory, for a few tests of specific facilities provided here
- the ``mostly-obsolete`` subdirectory, for the scripts we deprecated




-------
Support
-------

Bugs, questions, remarks, patches, requests for enhancements, etc. are to be reported to the `project interface <https://github.com/Olivier-Boudeville/Ceylan-Hull>`_ (typically `issues <https://github.com/Olivier-Boudeville/Ceylan-Hull/issues>`_) or directly at the email address mentioned at the beginning of this longer document.



-------------
Please React!
-------------

If you have information more detailed or more recent than those presented in this document, if you noticed errors, neglects or points insufficiently discussed, drop us a line! (for that, follow the Support_ guidelines).



-----------
Ending Word
-----------

Have fun with Ceylan-Hull!

:raw-html:`<center><img src="hull-title.png" width="15%"></img></center>`
:raw-latex:`\begin{figure}[h] \centering \includegraphics[scale=0.2]{hull-title.png} \end{figure}`

:raw-html:`<a name="hull_bottom"></a>`
