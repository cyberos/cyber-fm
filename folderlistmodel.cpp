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

#include "folderlistmodel.h"
#include <QDebug>

FolderListModel::FolderListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_fileLoader(new FileLoader)
    , m_selection(new DirSelection(this, &m_datas))
    , m_status(FolderListModel::Null)
{
    // Init
    qRegisterMetaType<FileItems>("QList<FileItem>");
    qRegisterMetaType<FolderListModel::Status>("FolderListModel::Status");

    connect(m_fileLoader, &FileLoader::itemReady, this, &FolderListModel::onItemAdded);

    connect(this, &FolderListModel::rowCountChanged, this, &FolderListModel::countChanged);

    setPath(QDir::homePath());
}

int FolderListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return m_datas.size();
}

QModelIndex FolderListModel::index(int row, int, const QModelIndex &) const
{
    return createIndex(row, 0);
}

QVariant FolderListModel::data(const QModelIndex &index, int role) const
{
    FileItem *item = m_datas.at(index.row());

    switch (role) {
    case FileNameRole:
        return item->fileName();
        break;
    case FilePathRole:
        return item->filePath();
        break;
    case FileBaseNameRole:
        return item->baseName();
        break;
    case FileSizeRole:
        return item->size();
        break;
    case FileIsDirRole:
        return item->isDir();
        break;
    case IconNameRole: {
        return QString("image://icontheme/%1").arg(item->mimeType().iconName());
    }
        break;
    case IconSourceRole: {
        if (item->mimeType().name() == "image/svg+xml")
            return QString("file://%1").arg(item->filePath());

        if (item->mimeType().name().startsWith("image/"))
            return QString("file://%1").arg(item->filePath());

        return QString();
    }
        break;
    case CreationDateRole:
        return item->created();
        break;
    case ModifiedDateRole:
        return item->lastModified();
        break;
    case IsSelectedRole:
        return item->isSelected();
        break;
    default:
        break;
    }

    return QVariant();
}

QHash<int, QByteArray> FolderListModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[FileNameRole] = "fileName";
    roleNames[FilePathRole] = "filePath";
    roleNames[FileBaseNameRole] = "fileBaseName";
    roleNames[FileSuffixRole] = "fileSuffix";
    roleNames[FileSizeRole] = "fileSize";
    roleNames[FileLastModifiedRole] = "fileModified";
    roleNames[FileLastReadRole] = "fileAccessed";
    roleNames[FileIsDirRole] = "fileIsDir";
    roleNames[FileUrlRole] = "fileUrl";
    roleNames[FileURLRole] = "fileURL";
    roleNames[IconNameRole] = "iconName";
    roleNames[IconSourceRole] = "iconSource";
    roleNames[CreationDateRole] = "creationDate";
    roleNames[ModifiedDateRole] = "modifiedDate";
    roleNames[IsSelectedRole] = "isSelected";
    return roleNames;
}

void FolderListModel::notifyItemChanged(int index)
{
    QModelIndex idx = QAbstractListModel::index(index, 0);
    emit dataChanged(idx, idx);
}

QString FolderListModel::path() const
{
    return m_currentDir;
}

void FolderListModel::setPath(const QString &filePath)
{
    if (filePath == m_currentDir)
        return;

    QFileInfo info(filePath);

    if (!info.exists() || !info.isDir()) {
        return;
    }

    // Handle path list
    m_pathList.clear();
    QString _path = filePath + "/";
    // while (_path.endsWith("/"))
    //     _path.chop(1);

    int count = _path.count("/");

    for (int i = 0; i < count; ++i) {
        _path = QString(_path).left(_path.lastIndexOf("/"));

        QString dirName = QString(_path).right(_path.length() - _path.lastIndexOf("/") - 1);

        if (dirName.isEmpty())
            continue;

        m_pathList << dirName;
    }

    std::reverse(m_pathList.begin(), m_pathList.end());

    m_currentDir = filePath;

    beginResetModel();
    m_datas.clear();
    endResetModel();

    m_fileLoader->setPath(filePath, dirFilters());

    emit pathChanged();
    emit rowCountChanged();
}

FolderListModel::Status FolderListModel::status() const
{
    return m_status;
}

DirSelection *FolderListModel::selection() const
{
    return m_selection;
}

QStringList FolderListModel::pathList() const
{
    return m_pathList;
}

void FolderListModel::openIndex(int index)
{
    FileItem *item = m_datas.at(index);

    // Open Directory.
    if (item->isDir()) {
        setPath(item->filePath());
    }
}

void FolderListModel::openPath(const QString &path)
{
    // Open from pathbar
    QString newPath = m_currentDir.left(m_currentDir.indexOf(path) + path.length());
    setPath(newPath);
}

QDir::Filters FolderListModel::dirFilters() const
{
    QDir::Filters filter;
    // show files
    filter = filter | QDir::Files;
    // show dirs
    filter = filter | QDir::AllDirs | QDir::Drives;
    // showDotAndDotDot
    filter = filter | QDir::NoDot | QDir::NoDotDot;

    return filter;
}

void FolderListModel::onItemAdded(FileItem *item)
{
    beginInsertRows(QModelIndex(), m_datas.count(), m_datas.count());
    m_datas.append(item);
    endInsertRows();

    emit rowCountChanged();
}
