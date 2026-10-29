#!/bin/sh
# Cross-build ttrss for the Nokia N9 (Harmattan PR1.3) on a Linux PC, without
# the old Qt SDK: clang (armhf, hard-float) + GNU ld, Harmattan Qt 4.7.4
# headers and libraries, and the Harmattan moc/rcc/lrelease run in qemu-arm.
#
# TC must contain:
#   hdr/     Ubuntu armhf cross files (libc6-dev-armhf-cross, libstdc++-13-dev-armhf-cross,
#            libgcc-13-dev-armhf-cross, binutils-arm-linux-gnueabihf), unpacked
#   rt/      N9 runtime libraries (libqt4-*, libqtcore4, libqtgui4, libc6, libstdc++6,
#            applauncherd-launcher ...) unpacked from the N9 001 repository mirror
#   qtdev/   Harmattan SDK libqt4-dev, applauncherd-dev, qt4-linguist-tools, unpacked
#   sdkc/    Harmattan SDK libc6-dev (crt*.o, libc_nonshared.a): the startup files
#            of the new glibc do not run static constructors with the N9 glibc 2.10
#   ld-arm   wrapper that runs hdr/usr/bin/arm-linux-gnueabihf-ld
set -e
TC=${TC:-/tmp/claude-0/x/tc}
SRC=$(cd "$(dirname "$0")/.." && pwd)
OUT=${OUT:-$SRC/build-n9}
VERSION=$(sed -n 's/^VERSION = //p' "$SRC/ttrss.pro")
H=$TC/hdr/usr/arm-linux-gnueabihf
G=$TC/hdr/usr/lib/gcc-cross/arm-linux-gnueabihf/13
Q=$TC/qtdev/usr/include/qt4
C=$TC/sdkc/usr/lib
BIN=$TC/qtdev/usr/bin
export QEMU_LD_PREFIX=$TC/rt
RUN="qemu-arm-static"

mkdir -p "$OUT"
cd "$SRC"

# translations and resources
for t in i18n/qml-translation.*.ts; do
    $RUN $BIN/host-lrelease -silent "$t" -qm "${t%.ts}.qm"
done
$RUN $BIN/host-rcc -name harmattan harmattan.qrc -o "$OUT/qrc_harmattan.cpp"

# moc
for h in settings.hh mynetworkmanager.hh qmlutils.hh theme.hh qmlapplicationviewer/qmlapplicationviewer.h; do
    b=$(basename "$h"); b=${b%.*}
    $RUN $BIN/host-moc -DQ_OS_HARMATTAN "$h" -o "$OUT/moc_$b.cpp"
done

T="--target=arm-linux-gnueabihf -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard -mthumb"
CF="$T -O2 -fPIE -nostdinc -isystem $(clang -print-resource-dir)/include -isystem $H/include/c++/13 -isystem $H/include/c++/13/arm-linux-gnueabihf -isystem $H/include -U_FORTIFY_SOURCE -D_FILE_OFFSET_BITS=32"
DEFS="-DQT_NO_DEBUG -DQT_SHARED -DQ_OS_HARMATTAN -DHARMATTAN_BOOSTER -DAPP_VERSION=\"$VERSION\" -DTARGET=\"ttrss\""
INC="-I$TC/qtdev/usr/share/qt4/mkspecs/linux-g++-maemo -I$Q -I$Q/QtCore -I$Q/QtGui -I$Q/QtNetwork -I$Q/QtDeclarative -I$Q/QtDBus -I$TC/qtdev/usr/include/applauncherd -I$SRC -I$SRC/qmlapplicationviewer -I$OUT"

OBJS=""
for c in main.cpp settings.cpp mynetworkmanager.cpp qmlutils.cpp theme.cpp qmlapplicationviewer/qmlapplicationviewer.cpp \
         "$OUT"/moc_*.cpp "$OUT/qrc_harmattan.cpp"; do
    o="$OUT/$(basename "${c%.cpp}").o"
    clang++ $CF -std=gnu++98 -fno-exceptions -fno-threadsafe-statics -fvisibility=hidden -fvisibility-inlines-hidden $DEFS $INC -c "$c" -o "$o"
    OBJS="$OBJS $o"
done

L=$TC/rt/usr/lib
clang++ $T --ld-path=$TC/ld-arm -pie -nostdlib -rdynamic -Wl,--allow-shlib-undefined -Wl,--as-needed \
  -Wl,--hash-style=both -Wl,-z,norelro -Wl,-dynamic-linker,/lib/ld-linux.so.3 \
  $C/Scrt1.o $C/crti.o $G/crtbeginS.o $OBJS \
  $L/libmdeclarativecache.so.0 $L/libQtDeclarative.so.4 $L/libQtDBus.so.4 $L/libQtNetwork.so.4 $L/libQtGui.so.4 $L/libQtCore.so.4 \
  $L/libstdc++.so.6 $TC/rt/lib/libm.so.6 $TC/rt/lib/libc.so.6 $C/libc_nonshared.a $TC/rt/lib/libgcc_s.so.1 \
  $G/crtendS.o $C/crtn.o -o "$OUT/ttrss"
llvm-strip "$OUT/ttrss" 2>/dev/null || true
echo "built $OUT/ttrss ($VERSION)"
