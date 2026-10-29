#!/bin/sh
# Build ttrss_<version>_armel.deb from the build-n9.sh output.
set -e
SRC=$(cd "$(dirname "$0")/.." && pwd)
OUT=${OUT:-$SRC/build-n9}
VERSION=$(sed -n 's/^VERSION = //p' "$SRC/ttrss.pro")
P=$OUT/pkg
rm -rf "$P"
mkdir -p "$P/DEBIAN" "$P/opt/ttrss/bin" "$P/opt/ttrss/qml" "$P/opt/ttrss/splash" \
         "$P/usr/share/applications" "$P/usr/share/icons/hicolor/80x80/apps" "$P/usr/share/doc/ttrss"

install -m 755 "$OUT/ttrss" "$P/opt/ttrss/bin/ttrss"
for d in models harmattan components resources; do
    cp -r "$SRC/qml/ttrss/$d" "$P/opt/ttrss/qml/$d"
done
cp "$SRC/images/ttrss-splash-portrait.jpg" "$SRC/images/ttrss-splash-landscape.jpg" "$P/opt/ttrss/splash/"
cp "$SRC/images/ttrss80.png" "$P/usr/share/icons/hicolor/80x80/apps/ttrss80.png"
cp "$SRC/ttrss_harmattan.desktop" "$P/usr/share/applications/ttrss_harmattan.desktop"
cp "$SRC/packaging/copyright" "$P/usr/share/doc/ttrss/copyright"
find "$P" -type d -exec chmod 755 {} +
find "$P/opt/ttrss/qml" "$P/opt/ttrss/splash" "$P/usr" -type f -exec chmod 644 {} +

ICON=$(base64 -w0 "$SRC/images/ttrss64.png")
SIZE=$(du -sk "$P" | cut -f1)
cat > "$P/DEBIAN/control" <<CTL
Package: ttrss
Version: $VERSION
Architecture: armel
Maintainer: N9 projekt <n9@localhost>
Installed-Size: $SIZE
Depends: applauncherd-launcher, libc6 (>= 2.4), libgcc1 (>= 1:4.1.1), libstdc++6 (>= 4.4.0), libqtcore4 (>= 4.7.4~), libqtgui4 (>= 4.7.4~), libqt4-network (>= 4.7.4~), libqt4-declarative (>= 4.7.4~), libqt4-dbus (>= 4.7.4~), qt-components
Section: user/internet
Priority: optional
Homepage: https://github.com/smyhu/ttrss-n9
Description: Tiny Tiny RSS reader for the Nokia N9
 Client for Tiny Tiny RSS servers, written in Qt/QML by Hauke Schade
 (cnlpete). Version revived for the N9 in 2026 by Claude (Anthropic)
 together with smyhu: works with current tt-rss servers, feed icons,
 Polish translation, new icon.
Maemo-Display-Name: Tiny Tiny RSS
Maemo-Icon-26: $ICON
CTL
(cd "$P" && find opt usr -type f -exec md5sum {} + > DEBIAN/md5sums)
dpkg-deb -Zgzip --root-owner-group -b "$P" "$OUT/ttrss_${VERSION}_armel.deb" >/dev/null
echo "$OUT/ttrss_${VERSION}_armel.deb"
