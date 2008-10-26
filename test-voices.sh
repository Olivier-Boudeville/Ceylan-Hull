#!/bin/sh

# See also: Content-indexing/audio/speech-synthesis
 
USAGE="  Usage: "`basename $0`" 

  Tests all voices by recording a test sentence with each of them, and comparing the MD5sum for each resulting WAV file.
"

test_message="This is a test sentence. Esperide Software presents: In the Hall of the Mountain King."

voice_id_max=37

current_voice=1

while [ $current_voice -le $voice_id_max ] ; do

	echo " - testing voice #$current_voice"

	record-speech.sh --voice-id $current_voice --speech-prefix voice-test-$current_voice --message "${test_message}" --ogg-encoding
	
	current_voice=$((current_voice+1))
    
done

