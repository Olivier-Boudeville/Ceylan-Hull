#!/bin/sh

# To be run for example in Content-repository/audio/speech-synthesis.

# Largely inspired from: http://ubuntuforums.org/showthread.php?t=751169


echo "Installing speech syntheses"

sudo apt-get update

INSTALL="sudo apt-get install"

echo "  Managing espeak"
${INSTALL} espeak


echo "  Managing festival (total: 19 voices)"
${INSTALL} festival festlex-cmu festlex-poslex festlex-oald libestools1.2 unzip




FESTVOX_VOICES="kal_diphone ked_diphone rab_diphone don_diphone"

echo "   - Festvox Diphone Voices (4 voices: ${FESTVOX_VOICES})"

${INSTALL} festvox-rablpc16k festvox-don festvox-kdlpc16k festvox-kallpc16k





CMU_VOICES="cmu_us_rms_arctic_clunits cmu_us_ksp_arctic_clunits
cmu_us_slt_arctic_clunits cmu_us_clb_arctic_clunits cmu_us_awb_arctic_clunits
cmu_us_jmk_arctic_clunits cmu_us_bdl_arctic_clunits"

echo "   - Enhanced CMU Arctic voices (7 voices: ${CMU_VOICES})"

# awb_arctic-0.90 should be like awb_arctic-0.95:
CMU_VOICE_FILES="awb_arctic-0.95 bdl_arctic-0.95 clb_arctic-0.95 jmk_arctic-0.95 ksp_arctic-0.95 rms_arctic-0.95 slt_arctic-0.95"

for v in ${CMU_VOICE_FILES}; do wget -c  http://www.speech.cs.cmu.edu/cmu_arctic/packed/cmu_us_${v}-release.tar.bz2; done

for v in ${CMU_VOICE_FILES}; do tar xjf cmu_us_${v}-release.tar.bz2 ; done

sudo mkdir -p /usr/share/festival/voices/english

for v in cmu_us_*arctic; do sudo ln -sf `pwd`/${v} /usr/share/festival/voices/english/${v}_clunits; done




NITECH_VOICES="nitech_us_awb_arctic_hts nitech_us_rms_arctic_hts nitech_us_slt_arctic_hts nitech_us_jmk_arctic_hts nitech_us_clb_arctic_hts nitech_us_bdl_arctic_hts cstr_us_ked_timit_hts cmu_us_kal_com_hts"

echo "   - Enhanced Nitech HTS voices (8 voices: ${NITECH_VOICES})"

NITECH_VOICE_FILES="2.1/festvox_nitech_us_awb_arctic_hts-2.1.tar.bz2 2.1/festvox_nitech_us_bdl_arctic_hts-2.1.tar.bz2 2.1/festvox_nitech_us_clb_arctic_hts-2.1.tar.bz2 2.1/festvox_nitech_us_rms_arctic_hts-2.1.tar.bz2 2.1/festvox_nitech_us_slt_arctic_hts-2.1.tar.bz2 2.1/festvox_nitech_us_jmk_arctic_hts-2.1.tar.bz2 1.1.1/cmu_us_kal_com_hts.tar.gz 1.1.1/cstr_us_ked_timit_hts.tar.gz"


for v in ${NITECH_VOICE_FILES} ; do wget -c http://hts.sp.nitech.ac.jp/archives/${v}; done

for v in festvox_nitech*.tar.bz2; do tar xjf ${v}; done

for v in cmu_us_kal_com_hts.tar.gz cstr_us_ked_timit_hts.tar.gz; do tar xzf ${v}; done

sudo mkdir -p /usr/share/festival/voices/us
sudo mv lib/voices/us/* /usr/share/festival/voices/us/
sudo mv lib/hts.scm /usr/share/festival/hts.scm




echo " Available voices are: "
/bin/ls /usr/share/festival/voices/*

echo "Check with the '(voice.list)' interactive command."

# We should end up with:
#festival> (voice.list)
#(nitech_us_awb_arctic_hts
# nitech_us_rms_arctic_hts
# nitech_us_slt_arctic_hts
# nitech_us_jmk_arctic_hts
# nitech_us_clb_arctic_hts
# nitech_us_bdl_arctic_hts
# cstr_us_ked_timit_hts
# cmu_us_kal_com_hts
# cmu_us_rms_arctic_clunits
# kal_diphone
# cmu_us_ksp_arctic_clunits
# cmu_us_slt_arctic_clunits
# ked_diphone
# rab_diphone
# cmu_us_clb_arctic_clunits
# cmu_us_awb_arctic_clunits
# cmu_us_jmk_arctic_clunits
# don_diphone
# cmu_us_bdl_arctic_clunits)
