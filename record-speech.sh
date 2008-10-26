#!/bin/sh


USAGE="  Usage: "`basename $0`" --voice-id <voice identifier> --speech-prefix <speech identifier> --message <message> [--no-play-back] [--ogg-encoding] [--verbose]

  Records the specified speech with specified voice in specified prefixed filename, and plays it back to check it.
      --voice-id <voice identifier>: the ID of the voice to be used (see Voice-index.rst)
      --speech-prefix <speech prefix>: trhe prefix to be used for the speech filename record
      --message <message>: the message to speech
      --no-play-back: disables play-back of the generated sound
      --ogg-encoding: encodes in Ogg Vorbis with default settings the resulting speech
      --verbose: be verbose
"

# Defaults:
play_back=0
ogg_encoding=1
verbose=1

playback_tool="play-sounds.sh"
encoder_tool="oggenc"


voice_id=0
speech_prefix=""
message=""


while [ $# -gt 0 ] ; do
	token_eaten=1
	
	if [ "$1" = "--voice-id" ] ; then
    	shift
        voice_id=$1
		token_eaten=0
	fi

	if [ "$1" = "--speech-prefix" ] ; then
    	shift
		speech_prefix="$1"
		token_eaten=0
	fi

	if [ "$1" = "--message" ] ; then
    	shift
		message="$1"
		token_eaten=0
	fi

	if [ "$1" = "--no-play-back" ] ; then
		play_back=1
		token_eaten=0
	fi

	if [ "$1" = "--ogg-encoding" ] ; then
		ogg_encoding=0
		token_eaten=0
	fi

	if [ "$1" = "--verbose" ] ; then
		verbose=0
		token_eaten=0
	fi

	
	if [ "$1" = "-h" -o "$1" = "--help" ] ; then
		echo "$USAGE"
		exit
		token_eaten=0
	fi

	if [ $token_eaten -eq 1 ] ; then
		echo "Error, unknown argument ($1)." 1>&2
		echo "${USAGE}" 1>&2
        exit 5
	fi	
	shift
    
done


if [ $voice_id -eq 0 ] ; then
	
	echo "Error, no voice identifier specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 6
        
fi


if [ "$speech_prefix" = "" ] ; then
	
	echo "Error, no speech prefix specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 7
        
fi


if [ -z "$message" ] ; then
	
	echo "Error, no message specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 8
        
fi


if [ $verbose -eq 0 ] ; then

	if [ $play_back -eq 0 ] ; then
    	echo " - play-back selected"
	else
    	echo " - play-back not selected"
	fi
    
            
	if [ $ogg_encoding -eq 0 ] ; then
    	echo " - OggVorbis encoding selected"
	else
    	echo " - OggVorbis encoding not selected"
	fi
    
    echo " - voice identifier: $voice_id"
    
    echo " - speech prefix: $speech_prefix"
    
    echo " - message: $message"

fi


if [ $play_back -eq 0 ] ; then

	if [ ! -x "${playback_tool}" ] ; then
	
    	echo "Error, playback tool not found (${playback_tool})." 1>&2
		exit 9
        
    fi
    
fi


# This matching between the voice ID and the tool and voice to use
# must correspond to Content-indexing/audio/speech-synthesis/Voice-index.rst 

tool=""
voice=""

case $voice_id in 

	1)
    	tool="espeak"
        voice="english"
        ;;
    
	2)
    	tool="espeak"
        voice="english-us"
        ;;
	3)
    	tool="espeak"
        voice="en-scottish"
        ;;
	4)
    	tool="espeak"
        voice="default"
        ;;
	5)
    	tool="espeak"
        voice="lancashire"
        ;;
	6)
    	tool="espeak"
        voice="en-westindies"
        ;;
    
	7)
    	tool="espeak"
        voice="english_rp"
        ;;
    
	8)
    	tool="espeak"
        voice="english_wmids"
        ;;
    
	9)
    	tool="espeak"
        voice="french"
        ;;
    
	10)
    	tool="espeak"
        voice="female1"
        ;;
    
	11)
    	tool="espeak"
        voice="female2"
        ;;
    
	12)
    	tool="espeak"
        voice="female3"
        ;;
    
	13)
    	tool="espeak"
        voice="female4"
        ;;
    
	14)
    	tool="espeak"
        voice="male1"
        ;;
    
	15)
    	tool="espeak"
        voice="male2"
        ;;
    
	16)
    	tool="espeak"
        voice="male3"
        ;;
    
	17)
    	tool="espeak"
        voice="male4"
        ;;
    
	18)
    	tool="espeak"
        voice="male6"
        ;;
    
	19)
    	tool="espeak"
        voice="whisper"
        ;;
    
	20)
    	tool="espeak"
        voice="croak"
        ;;
    
    21)
    	tool="festival"
        voice="cmu_us_awb_arctic_clunits"
        ;;
    
    22)
    	tool="festival"
        voice="cmu_us_bdl_arctic_clunits"
        ;;
    
    23)
    	tool="festival"
        voice="cmu_us_clb_arctic_clunits"
        ;;
    
    24)
    	tool="festival"
        voice="cmu_us_jmk_arctic_clunits"
        ;;
    
    25)
    	tool="festival"
        voice="cmu_us_ksp_arctic_clunits"
        ;;
    
    26)
    	tool="festival"
        voice="cmu_us_rms_arctic_clunits"
        ;;
    
    27)
    	tool="festival"
        voice="cmu_us_slt_arctic_clunits"
        ;;
    
    28)
    	tool="festival"
        voice="nitech_us_awb_arctic_hts"
        ;;
    
    29)
    	tool="festival"
        voice="nitech_us_bdl_arctic_hts"
        ;;
    
    30)
    	tool="festival"
        voice="nitech_us_clb_arctic_hts"
        ;;
    
    31)
    	tool="festival"
        voice="nitech_us_jmk_arctic_hts"
        ;;
    
    32)
    	tool="festival"
        voice="nitech_us_rms_arctic_hts"
        ;;
    
    33)
    	tool="festival"
        voice="nitech_us_slt_arctic_hts"
        ;;
    
    34)
    	tool="festival"
        voice="kal_diphone"
        ;;
    
    35)
    	tool="festival"
        voice="ked_diphone"
        ;;
    
    36)
    	tool="festival"
        voice="rab_diphone"
        ;;
    
    37)
    	tool="festival"
        voice="don_diphone"
        ;;
       
    *)
    	echo "Error, voice identifier #$voice_id not known." 1>&2
        exit 10
    	;;    
        
esac

target_wav="$speech_prefix.wav"


if [ "$tool" = "espeak" ] ; then

	# Default amplitude, pitch and speed left as default:
	espeak -v $voice -w "$target_wav" "$message"
    
else 

	if [ "$tool" = "festival" ] ; then

		echo "$message" | text2wave -otype riff -o "$target_wav" -eval "(voice_$voice)"
    
	else
	
    	echo "Error, tool '$tool' not known." 1>&2
	    exit 11
        
    fi
    
fi


if [ ! -f "$target_wav" ] ; then

    echo "Error, produced WAV not found ($target_wav)." 1>&2
    exit 12
	
fi

effectice_target="$target_wav"

if [ $ogg_encoding -eq 0 ] ; then

	target_ogg="$speech_prefix.ogg"
    
	${encoder_tool} "$target_wav" --quality=3 --output="$target_ogg" 1>/dev/null 2>&1
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, encoding failed." 1>&2
	fi
    
    effectice_target="$target_ogg"
    
fi


if [ $play_back -eq 0 ] ; then

	${playback_tool} "$effectice_target"
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, playback failed." 1>&2
	fi
        
fi
