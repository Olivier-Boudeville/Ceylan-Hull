#!/bin/sh

# See also: Content-indexing/audio/speech-synthesis/Espeak-without-MBROLA.rst
 
USAGE="  Usage: "`basename $0`" 

  Tests espeak voices by recording a test sentence with each of them, and comparing the MD5sum for each resulting WAV file.
"


# Returns the list of voices for specified voice type.
get_espeak_voice_for()
{
	voice_type=$1
	returned_voices=`espeak --voices=${voice_type} |grep -v mb | awk '{ print $4 }'|grep -v VoiceName|grep -v mbrola`
}



get_espeak_voice_for en
ESPEAK_EN_VOICES="${returned_voices}"

get_espeak_voice_for fr
ESPEAK_FR_VOICES="${returned_voices}"

get_espeak_voice_for variant
ESPEAK_VARIANT_VOICES="${returned_voices}"

ESPEAK_VOICES="${ESPEAK_EN_VOICES} ${ESPEAK_FR_VOICES} ${ESPEAK_VARIANT_VOICES}"

#echo "ESPEAK_VOICES = ${ESPEAK_VOICES}"

for v in ${ESPEAK_VOICES} ; do echo "Voice = $v" ;  echo "Esperide Software presents: In the Hall of the Mountain King." |  espeak -v $v -w $v.wav; play-sounds.sh --quiet $v.wav ; done  

ESPEAK_RETAINED_LIST=""

/bin/rm -f voices-md5-unsorted.txt voices-md5-sorted.txt

for f in *.wav; do md5sum $f >> voices-md5-unsorted.txt ; done

cat voices-md5-unsorted.txt | sort >> voices-md5-sorted.txt

