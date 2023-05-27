#!/bin/bash
cecho(){
    RED="\033[0;31m"
    GREEN="\033[0;32m"  # <-- [0 means not bold
    YELLOW="\033[1;33m" # <-- [1 means bold
    CYAN="\033[1;36m"
    # ... Add more colors if you like

    NC="\033[0m" # No Color

    # printf "${(P)1}${2} ${NC}\n" # <-- zsh
    printf "${!1}${2} ${NC}\n" # <-- bash
}

WD=`pwd`
WDNAME=`basename "$PWD"`
if [ $WDNAME != "epu-build-tools" ]
    then
    cecho "RED" "It looks like I'm being run from the wrong place." echo
    cecho "RED"  "Run me from inside a directory called "epu-build-tools/" alongside the required files:" echo
    cecho "RED"  "pwd: "$WD echo
    echo "Files required for this script:"
    echo " e600fe49f91c982f681de41ef6fb36b1d6df2e4c41b3e2114d024f4a3bea3ffc  patchelf   "
    echo " 10b05608eeec73ddb6e10c040e5d3483682e92b43e37f21934112cb391f9de02  x86_64-linux-gnu-ar-2.26"
    echo " 4e5671394ae13ed3599050093023c23e6b53dd5d00b9a5ff6730fc2ec2afcd50  libbfd-2.26.1-system.so"
    exit
fi

echo "Files required for this script:"
echo " e600fe49f91c982f681de41ef6fb36b1d6df2e4c41b3e2114d024f4a3bea3ffc  patchelf   "
echo " 10b05608eeec73ddb6e10c040e5d3483682e92b43e37f21934112cb391f9de02  x86_64-linux-gnu-ar-2.26"
echo " 4e5671394ae13ed3599050093023c23e6b53dd5d00b9a5ff6730fc2ec2afcd50  libbfd-2.26.1-system.so"

if [ -x ./patchelf ]
    then
    PATCHELF_PRESENT=true
    echo "e600fe49f91c982f681de41ef6fb36b1d6df2e4c41b3e2114d024f4a3bea3ffc  patchelf" | sha256sum -c - 1>/dev/null
    RETVAL=$?;
    if [ "$RETVAL" -eq 0 ]
        then
        cecho "GREEN" "patchelf: OK" echo
    fi
    else
    cecho "RED" $WD\/"patchelf  - not found!" echo
    cecho "RED" "Files required for this script:" echo
    cecho "RED" " e600fe49f91c982f681de41ef6fb36b1d6df2e4c41b3e2114d024f4a3bea3ffc  patchelf   " echo
    cecho "GREEN" "Available at: https://github.com/caroli-magni/epu-build-tools/raw/main/patchelf" echo
    exit
fi

if [ -x ./x86_64-linux-gnu-ar-2.26 ]
    then
    AR_PRESENT=true
    echo "10b05608eeec73ddb6e10c040e5d3483682e92b43e37f21934112cb391f9de02  x86_64-linux-gnu-ar-2.26" | sha256sum -c - 1>/dev/null
    RETVAL=$?;
    if [ "$RETVAL" -eq 0 ]
        then
        cecho "GREEN" "x86_64-linux-gnu-ar-2.26: OK" echo
    fi
    ./x86_64-linux-gnu-ar-2.26 2>/dev/null
    RETVAL=$?
    if [ "$RETVAL" -eq 1 ]
        then
        cecho "GREEN" "x86_64-linux-gnu-ar-2.26 - patched!" echo

    fi
    if [ "$RETVAL" -eq 127 ]
        then
        cecho "RED" $WD\/"x86_64-linux-gnu-ar-2.26 - not patched!" echo
        exit
    fi
    else
    cecho "RED" $WD\/"x86_64-linux-gnu-ar-2.26 - not found!" echo
    cecho "RED" "Files required for this script:" echo
    cecho "RED" " 10b05608eeec73ddb6e10c040e5d3483682e92b43e37f21934112cb391f9de02  x86_64-linux-gnu-ar-2.26" echo
    cecho "GREEN" "Available at: https://github.com/caroli-magni/epu-build-tools/raw/main/x86_64-linux-gnu-ar-2.26" echo
    exit
fi

if [ -s ./libbfd-2.26.1-system.so ]
    then
    LIBBFD_PRESENT=true
    echo "4e5671394ae13ed3599050093023c23e6b53dd5d00b9a5ff6730fc2ec2afcd50  libbfd-2.26.1-system.so" | sha256sum -c - 1>/dev/null
    RETVAL=$?;
    if [ "$RETVAL" -eq 0 ]
        then
        cecho "GREEN" "libbfd-2.26.1-system.so: OK" echo
    fi
    else
    cecho "RED" $WD\/"libbfd-2.26.1-system.so - not found!" echo
    cecho "RED"  "Files required for this script:" echo
    cecho "RED" " 4e5671394ae13ed3599050093023c23e6b53dd5d00b9a5ff6730fc2ec2afcd50  libbfd-2.26.1-system.so" echo
    cecho "GREEN" "Available at: https://github.com/caroli-magni/epu-build-tools/raw/main/libbfd-2.26.1-system.so" echo
    exit
fi

echo "Downloading the epson-printer-utility .deb installation package..."
wget https://download3.ebz.epson.net/dsc/f/03/00/14/48/17/b62b6bb593b3262a4df82f55161c89d0c776de21/epson-printer-utility_1.1.1-1lsb3.2_amd64.deb -O epu.deb -nv
echo "Extracting the EPU .deb package..."
./x86_64-linux-gnu-ar-2.26 -x epu.deb
echo "Extracting the the inner tars..."
tar xf data.tar.gz
tar xf control.tar.gz
echo "Deleting unneeded files..."
rm postrm prerm preinst data.tar.gz control.tar.gz epu.deb control debian-binary




echo "Downloading the libaudio2 .deb installation package..."
wget http://launchpadlibrarian.net/331724376/libaudio2_1.9.4-6_amd64.deb -O libaudio2.deb -nv
echo "Extracting the libaudio2 .deb package..."
./x86_64-linux-gnu-ar-2.26 -x libaudio2.deb
tar xf data.tar.xz
echo "Cleaning up..."
rm data.tar.xz libaudio2.deb

echo "Downloading the libqtgui4 .deb installation package..."
wget http://launchpadlibrarian.net/261237166/libqtgui4_4.8.7+dfsg-7ubuntu1_amd64.deb -O libqtgui4.deb -nv
echo "Extracting the libqtgui4 .deb package..."
./x86_64-linux-gnu-ar-2.26 -x libqtgui4.deb
tar xf data.tar.xz
echo "Cleaning up..."
rm control.tar.gz data.tar.xz libqtgui4.deb

echo "Downloading the libqtcore4 .deb installation package..."
wget http://launchpadlibrarian.net/261237164/libqtcore4_4.8.7+dfsg-7ubuntu1_amd64.deb -O libqtcore4.deb -nv
echo "Extracting the libqtcore4 .deb package..."
./x86_64-linux-gnu-ar-2.26 -x libqtcore4.deb
tar xf data.tar.xz
echo "Cleaning up..."
rm control.tar.gz data.tar.xz libqtcore4.deb

echo "Patching .deb post-install script to use relative paths..."
# patch post-installation script to work with relative directories instead of default system paths
sed -i 's/\/usr\/lib\//.\/usr\/lib\//g' postinst
sed -i 's/\/opt\/epson-printer-utility\//.\/opt\/epson-printer-utility\//g' postinst
sed -i 's/cd \.\/usr\/lib\/epson-backend\/scripts\///g' postinst
sed -i 's/\.\/inst-/\.\/usr\/lib\/epson-backend\/scripts\/inst-/g' postinst

echo "Patching .deb post-install script to install LSB system pointers..."
# strip the shebang from the original postinst script
sed -i 's/\#\!\/bin\/bash//g' postinst
# take the old contents and put them elsewhere
mv postinst postinst.0
# insert new shebang and script lines that install LSB pointers necessary to run EPU and epson-backend
echo "#!/bin/bash
ln -sf ld-linux.so.2 /lib/ld-lsb.so.1
ln -sf ld-linux.so.2 /lib/ld-lsb.so.2
ln -sf ld-linux.so.2 /lib/ld-lsb.so.3
ln -sf ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.2
ln -sf ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
" > postinst
# concatenate old script contents on top of new
cat postinst.0 >> postinst
# delete temporary file
rm postinst.0

echo "Patching EPU post-install script to use relative paths..."
sed -i 's/\/usr\//\.\/usr\//g' ./usr/lib/epson-backend/scripts/inst-cups-post.sh
sed -i 's/\=\//\=\.\//g' ./usr/lib/epson-backend/scripts/inst-cups-post.sh

echo "Patching EPU system daemon installer to use relative paths..."
sed -i 's/sbindir\=\//sbindir\=\.\//g' ./usr/lib/epson-backend/rc.d/inst-rc_d.sh
sed -i 's/pkgrcddir\=\//pkgrcddir\=\.\//g' ./usr/lib/epson-backend/rc.d/inst-rc_d.sh

echo "Patching EPU system daemon startup script to use relative paths..."
sed -i 's/pkglibdir\=\//pkglibdir\=\.\//g' ./usr/lib/epson-backend/rc.d/ecbd
sed -i 's/pkgrcddir\=\//pkgrcddir\=\.\//g' ./usr/lib/epson-backend/rc.d/ecbd


echo "Patching EPU main binary to use /lib/ path for qt4libs+libaudio..."

patchelf --force-rpath --set-rpath '$ORIGIN/../lib/' ./opt/epson-printer-utility/bin/epson-printer-utility

cp -R ./usr/lib/x86_64-linux-gnu/*.so* ./opt/epson-printer-utility/lib/

