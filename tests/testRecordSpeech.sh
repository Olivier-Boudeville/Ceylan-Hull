#!/bin/sh

tested_script="record-speech.sh"

# See Asset-Indexing/audio/speech-synthesis/Voice-index.rst:
max_voice_count=37
	
echo "Testing ${tested_script} with ${max_voice_count} different voices."

cd ..

voice_count=1

while [ $voice_count -le $max_voice_count ] ; do

	echo "  + testing voice #$voice_count"
	
	${tested_script} --voice-id $voice_count --speech-prefix "tests/testRecordSpeech-$voice_count" --message "Testing now the voice #$voice_count."
	
    voice_count=$(($voice_count+1))
	
done

echo "Checking voices are all different indeed: "

md5sum tests/testRecordSpeech*

