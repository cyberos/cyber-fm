/*
 * Copyright (C) 2020 CyberOS Team.
 *
 * Author:     rekols <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "placesmodel.h"
#include <QDir>

PlacesModel::PlacesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    if (QFile::exists(locationHome()))
        m_locations.append(locationHome());
    if (QFile::exists(locationDocuments()))
        m_locations.append(locationDocuments());
    if (QFile::exists(locationDownloads()))
        m_locations.append(locationDownloads());
    if (QFile::exists(locationMusic()))
        m_locations.append(locationMusic());
    if (QFile::exists(locationPictures()))
        m_locations.append(locationPictures());
    if (QFile::exists(locationVideos()))
        m_locations.append(locationVideos());
}

QString PlacesModel::locationHome() const
{
    return standardLocation(QStandardPaths::HomeLocation);
}

QString PlacesModel::locationDocuments() const
{
    return standardLocation(QStandardPaths::DocumentsLocation);
}

QString PlacesModel::locationDownloads() const
{
    return standardLocation(QStandardPaths::DownloadLocation);
}

QString PlacesModel::locationMusic() const
{
    return standardLocation(QStandardPaths::MusicLocation);
}

QString PlacesModel::locationPictures() const
{
    return standardLocation(QStandardPaths::PicturesLocation);
}

QString PlacesModel::locationVideos() const
{
    return standardLocation(QStandardPaths::MoviesLocation);
}

int PlacesModel::rowCount(const QModelIndex &) const
{
    return m_locations.count();
}

QVariant PlacesModel::data(const QModelIndex &index, int roles) const
{
    switch (roles) {
    case PathRoles:
        return m_locations.at(index.row());
        break;
    case DisplayNameRoles:
        return QDir(m_locations.at(index.row())).dirName();
        break;
    }

    return m_locations.at(index.row());
}

QHash<int, QByteArray> PlacesModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(PlacesModel::PathRoles, "path");
    roles.insert(PlacesModel::DisplayNameRoles, "displayName");
    return roles;
}

QString PlacesModel::standardLocation(QStandardPaths::StandardLocation location) const
{
    QStringList locations = QStandardPaths::standardLocations(location);
    QString standardLocation = "";

    foreach (const QString &location, locations) {
        // We always return the first location or an empty string
        // The frontend should check out that it exists
        if (QDir(location).exists()) {
            standardLocation = location;
            break;
        }
    }

    return standardLocation;
}
