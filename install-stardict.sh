#!/bin/sh

USAGE="installs stardict and a set of default dictionaries."

if [ ! `id -u` -eq 0 ] ; then

   echo "Error, you must be root." 1>&2
   exit 5

fi

echo " - installing/updating stardict package"
apt-get -qq update && apt-get -qq install stardict
if [ ! $? -eq 0 ] ; then

	echo "Error, management of 'stardict' package failed." 1>&2
	exit 10

fi


### Dictionaries section.

# Browsed from http://www.huzheng.org/stardict-iso/stardict-dic/ and from
# http://www.dicts.info/dictionaries.php.

BASE_URL="http://www.huzheng.org/stardict-iso/stardict-dic"
VERSION="2.4.2"
SUFFIX="${VERSION}.tar.bz2"


## English to French.

# English - French:
EF1="${BASE_URL}/freedict.de/stardict-freedict-eng-fra-${SUFFIX}"

# quick_eng-fra:
EF2="${BASE_URL}/Quick/stardict-quick_eng-fra-${SUFFIX}"

# Larousse Chambers English-French:
EF3="${BASE_URL}/babylon/misc/stardict-babylon-Larousse_Chambers_English_Fren-${SUFFIX}"

# Babylon_English_French:
EF4="${BASE_URL}/babylon/bidirectional/stardict-babylon-Babylon_English_French-${SUFFIX}"

EF="${EF1} ${EF2} ${EF3} ${EF4}"



## French to English:

# freedict-fra-eng:
FE1="${BASE_URL}/freedict.de/stardict-freedict-fra-eng-${SUFFIX}"

# quick_fra-eng:
FE2="${BASE_URL}/Quick/stardict-quick_fra-eng-${SUFFIX}"

# Larousse Chambers français-anglais:
FE3="${BASE_URL}/babylon/misc/stardict-babylon-Larousse_Chambers_fran_ais_ang-${SUFFIX}"

# Babylon_French_English_diction:
FE4="${BASE_URL}/babylon/bidirectional/stardict-babylon-Babylon_French_English_diction-${SUFFIX}"

FE="${FE1} ${FE2} ${FE3} ${FE4}"




# Pure English:

# The Collaborative International Dictionary of English:
E1="${BASE_URL}/dict.org/stardict-dictd_www.dict.org_gcide-${SUFFIX}"

# Webster's Revised Unabridged Dictionary (1913):
E2="${BASE_URL}/dict.org/stardict-dictd-web1913-${SUFFIX}"

# Longman Dictionary of Contemporary English:
E3="${BASE_URL}/dict.org/stardict-longman-${SUFFIX}"

# Collins Cobuild English Dictionary:
E4="${BASE_URL}/dict.org/stardict-cced-${SUFFIX}"

# The Britannica Concise Encyclopedia:
E5="${BASE_URL}/dict.org/stardict-BritannicaConcise-${SUFFIX}"

# American Heritage Dictionary, 4th Edition - With image:
E6="${BASE_URL}/babylon/en/stardict-babylon-AHD4_2.8-${SUFFIX}"

# Oxford Advanced learner's Dictionary:
E7="${BASE_URL}/babylon/en/stardict-babylon-oxford_advanced_learner_dictionary-${SUFFIX}"

# Cambridge Advanced Learner's Dictionary:
E8="${BASE_URL}/babylon/en/stardict-babylon-cambridgev2_b13-${SUFFIX}"


E="${E1} ${E2} ${E3} ${E4} ${E5} ${E6} ${E7} ${E8}"



# Pure French:

# Dictionnaire de l’Académie Française, 8ème édition (1935):
F1="${BASE_URL}/fr/stardict-Dico_result_38.xdxf-${SUFFIX}"

# XMLittre French dictionnary Le Littré:
F2="${BASE_URL}/fr/stardict-xmlittre-${SUFFIX}"

F="${F1} ${F2}"



# Misc

# Jargon File:
M1="${BASE_URL}/dict.org/stardict-dictd-jargon-${SUFFIX}"

# Most Common Acronyms and Abbreviations:
M2="${BASE_URL}/babylon/en/stardict-babylon-MostCommonAcronymsAndAbbreviations-${SUFFIX}"

# Larousse Multidico:
M3="${BASE_URL}/babylon/misc/stardict-babylon-Larousse_Multidico-${SUFFIX}"


M="${M1} ${M2} ${M3}"


DICS="${EF} ${FE} ${E} ${F} ${M}"

# To install these tarball dictionaries, do this:
# tar -xjvf a.tar.bz2
# mv a /usr/share/stardict/dic

TARGET_DIR="/usr/share/stardict/dic"
cd ${TARGET_DIR}

# For testing: DICS="$M1"

for D in ${DICS}; do

	DIC_FILE=`basename $D`

	echo " - taking care of ${DIC_FILE}"
	wget -q $D
	if [ ! $? -eq 0 ] ; then

		echo "Error, download of $D failed." 1>&2
		exit 20

	fi

	tar xjf ${DIC_FILE} 1>/dev/null
	if [ ! $? -eq 0 ] ; then

		echo "Error, extraction of archive ${DIC_FILE} failed." 1>&2
		exit 25

	fi

	/bin/rm -f ${DIC_FILE}

done


echo "All dictionaries successfully installed! (in ${TARGET_DIR}), now you can run 'stardict 1>/dev/null 2>&1 &' as a normal user."
