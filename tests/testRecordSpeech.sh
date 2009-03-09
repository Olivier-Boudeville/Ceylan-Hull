#!/bin/sh

tested_script="record-speech.sh"

cd `dirname $0`

	
echo "Testing ${tested_script} with ${voice_index_max} different voices."

/bin/rm -f testRecordSpeech-*.wav

cd ..


voice_index_min=1

# See Asset-Indexing/audio/speech-synthesis/Voice-index.rst:
voice_index_max=37


while [ $voice_index_min -le $voice_index_max ] ; do

	if [ -n "${1}" ] ; then
		message="${1}"
	else
		message="Testing now the voice number $voice_index_min."
	fi
	
	echo "  + testing voice #$voice_index_min with '${message}'"
	
	${tested_script} --voice-id $voice_index_min --speech-prefix "tests/testRecordSpeech-$voice_index_min" --message "${message}"
	
	echo 
	
    voice_index_min=$(($voice_index_min+1))
	
done

echo "Checking voices are all different indeed: "

md5sum tests/testRecordSpeech-**.wav

