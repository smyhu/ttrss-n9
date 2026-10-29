/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

#include "qmlutils.hh"

#ifdef Q_OS_HARMATTAN
// Share UI is called over D-Bus directly, so the build does not need the
// MDataUri / shareuiinterface headers, which are no longer available.
#include <QtCore/QStringList>
#include <QtCore/QUrl>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusPendingCall>
#endif

QScopedPointer<QMLUtils> QMLUtils::m_instance(0);

QMLUtils::QMLUtils(QObject *parent) : QObject(parent) {
}

QMLUtils *QMLUtils::instance() {
    if (m_instance.isNull())
        m_instance.reset(new QMLUtils);

    return m_instance.data();
}

void QMLUtils::share(const QString &link, const QString &title) {
#ifdef Q_OS_HARMATTAN
    // data URI in the format produced by MDataUri: data:text/x-url;title=...,<link>
    QString uri = QLatin1String("data:text/x-url");
    if (!title.isEmpty())
        uri += QLatin1String(";title=") + QString::fromLatin1(QUrl::toPercentEncoding(title));
    uri += QLatin1Char(',') + QString::fromLatin1(QUrl::toPercentEncoding(link));

    QDBusInterface shareIf("com.nokia.ShareUi", "/", "com.nokia.maemo.meegotouch.ShareUiInterface",
                           QDBusConnection::sessionBus());

    if (!shareIf.isValid()) {
        qCritical("QMLUtils::shareLink(): Invalid Share UI interface");
        return;
    }

    shareIf.asyncCall("share", QStringList() << uri);
#else
    qWarning("QMLUtils::shareLink(): This function only available on Harmattan");
    Q_UNUSED(title)
    Q_UNUSED(link)
#endif
}
