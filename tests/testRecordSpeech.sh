#!/bin/sh

tested_script="record-speech.sh"

# See Asset-Indexing/audio/speech-synthesis/Voice-index.rst:
max_voice_count=37
	
echo "Testing ${tested_script} with ${max_voice_count} different voices."

/bin/rm -f testRecordSpeech-*.wav

cd ..

voice_count=1

while [ $voice_count -le $max_voice_count ] ; do

	message="Testing now the voice number $voice_count."
	
	echo "  + testing voice #$voice_count with '${message}'"
	
	${tested_script} --voice-id $voice_count --speech-prefix "tests/testRecordSpeech-$voice_count" --message "${message}"
	
    voice_count=$(($voice_count+1))
	
done

echo "Checking voices are all different indeed: "

md5sum tests/testRecordSpeech-**.wav

