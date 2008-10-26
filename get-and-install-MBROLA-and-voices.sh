#/bin/sh

# Update it regularly:
MBROLA_VERSION="301h"

if [ -n "$1" ] ; then
	install_dir="$1"
else    
	install_dir="$LOANI_INSTALLATIONS/MBROLA"
fi

echo "  Will install MBROLA and voices in directory ${install_dir}"

mkdir -p ${install_dir}

mkdir tmp-mbrola
cd tmp-mbrola

target_file="mbr${MBROLA_VERSION}.zip"

wget http://tcts.fpms.ac.be/synthesis/mbrola/bin/pclinux/${target_file}

unzip ${target_file}
/bin/cp -f mbrola-linux-i386 ${install_dir}/mbrola
    



cd ..

rm -rf tmp-mbrola

echo "MBROLA and voices successfully installed."

