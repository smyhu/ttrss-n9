ttrss for Nokia N9 (revival, 0.4.9)
==========

This is a fork of [cnlpete/ttrss](https://github.com/cnlpete/ttrss)
(tag `harmattan-v0.4.7`, by Hauke Schade) that makes the Harmattan app work
again with current Tiny Tiny RSS servers (tested with tt-rss 2025-04-25,
API level 18+).

Changes in 0.4.8–0.4.9:

* login works with new servers: `getConfig` no longer returns `icons_dir`,
  only `icons_url` (the app used to hang silently after login)
* feed icons are loaded from `public.php?op=feed_icon&id=N` on new servers
* new launcher icon in the style of our other N9 apps
* Polish translation (`i18n/qml-translation.pl.ts`); English stays the default
* faster article view (unused QtWebKit import removed), 30 MB image cache
* sharing uses the Share UI D-Bus service directly
* project links point to this fork
* 0.4.9: article view scrolls only vertically (it was slightly wider than the screen)

Install on the phone (as root, the package replaces the Ovi Store/OpenRepos one):

    aegis-dpkg -i /home/developer/ttrss_0.4.9_armel.deb

The ready package is in `dist/`. In the app settings use your server address
(e.g. `https://example.com/tt-rss`) and set *Minimum SSL Version* to *Any* if
the server does not accept TLS 1.0 (needs the N9 TLS 1.2 patch).

Building without the old Qt SDK: see `packaging/build-n9.sh` (clang + qemu-arm
with the Harmattan Qt 4.7.4 headers and libraries) and `packaging/make-deb.sh`.

Credits: original app by Hauke Schade and contributors (GPL-2+).
Revived for the Nokia N9 by Claude (Anthropic) together with
[smyhu](https://github.com/smyhu) (2026).

---

ttrss
==========

ttrss is a [Tiny Tiny RSS](http://tt-rss.org) Reader App for the
Nokia N9 smart phone, written using Qt/QML.
It uses the [Tiny Tiny RSS API](http://tt-rss.org/redmine/projects/tt-rss/wiki/JsonApiReference).

If you want to support me or this app, [buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WUWGSGAK8K7ZN) (in &euro;).

ArtWork
----------
* TinyTinyRSS Logo is taken from the [Android Project](http://tt-rss.org/redmine/projects/tt-rss-android/wiki/)
* All other Icons are free Icons provided by [IconFinder](http://www.iconfinder.com/search/?q=iconset%3Adevelopperss)
* The Harmattan Desktop Icon was generated using the amazing [Harmattan Icon Generator](http://apps.javispedro.com/nit/hicg/) by [Javier S. Pedro](https://gitorious.org/hicg/hicg)

Translations
----------

Translations are managed at [Transifex](https://www.transifex.com/). Feel free to contribute via [Transifex](https://www.transifex.com/projects/p/ttrss/resource/main/) or send me a [Pull Request](https://github.com/cnlpete/ttrss/pulls).

[![Translation Completion](https://www.transifex.com/projects/p/ttrss/resource/main/chart/image_png)](https://www.transifex.com/projects/p/ttrss/resource/main/)


License
----------

    Copyright (C) Hauke Schade, 2012-2014

    TTRss is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    TTRss is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with TTRss; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
    http://www.gnu.org/licenses/.
